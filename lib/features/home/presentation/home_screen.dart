import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/data/state/streak_notifier.dart';
import '../../../core/data/state/achievement_event_notifier.dart';
import '../../../core/data/models/achievement.dart';
import '../../../core/ui/widgets/confetti_widget.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../pomodoro/presentation/pomodoro_widget.dart';
import '../../monetization/presentation/rewarded_ad_button.dart';
import '../../social/domain/referral_rules.dart';
import '../../social/presentation/notifications_screen.dart';
import '../../social/presentation/social_providers.dart';
import '../../tasks/presentation/tasks_card.dart';
import 'daily_goal_card.dart';
import 'widgets/share_button.dart';
import '../../monetization/presentation/native_ad_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ProviderSubscription<AsyncValue<Achievement>>? _achievementSub;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();

    _achievementSub = ref.listenManual<AsyncValue<Achievement>>(
      achievementEventProvider,
      (previous, next) {
        next.whenData((achievement) {
          if (mounted) {
            _showAchievementDialog(context, achievement);
          }
        });
      },
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _collectReferralRewards(),
    );
  }

  Future<void> _collectReferralRewards() async {
    final friends = await claimReferralRewards(ref);
    if (friends > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .inviteRewardEarned(friends, friends * referralReferrerBonus),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _achievementSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final streakAsync = ref.watch(streakProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ZyraColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: streakAsync.when(
                      data: (streak) => _TopHeader(
                        totalPoints: userState.totalPoints,
                        totalMinutes: userState.totalStudyMinutes,
                        currentStreak: streak,
                        l10n: l10n,
                      ),
                      loading: () => const SizedBox(height: 80),
                      error: (_, __) => const SizedBox(height: 80),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: const PomodoroWidget()
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: const DailyGoalCard(),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: TasksCard(),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: NativeAdCard(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const RewardedAdButton()
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _MotivationCard(l10n: l10n)
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 600.ms),
                  ),
                ),
              ],
            ),
          ),
          IgnorePointer(
            child: ConfettiWidget(
              isVisible: _showConfetti,
              onComplete: () {
                if (mounted) setState(() => _showConfetti = false);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementDialog(
    BuildContext context,
    Achievement achievement,
  ) {
    setState(() => _showConfetti = true);

    final l10n = AppLocalizations.of(context);
    final isTr = l10n.localeName == 'tr';

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ZyraColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ZyraColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                achievement.iconEmoji,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.achievementUnlocked,
                style: ZyraTypography.headlineMedium.copyWith(
                  color: ZyraColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isTr ? achievement.nameTr : achievement.nameEn,
                style: ZyraTypography.titleMedium.copyWith(
                  color: ZyraColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  l10n.awesome,
                  style: ZyraTypography.labelLarge.copyWith(
                    color: ZyraColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  final int totalPoints;
  final int totalMinutes;
  final int currentStreak;
  final AppLocalizations l10n;

  const _TopHeader({
    required this.totalPoints,
    required this.totalMinutes,
    required this.currentStreak,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                '$currentStreak',
                style: ZyraTypography.titleMedium.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ZyraColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ZyraColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: ZyraColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$totalPoints',
                    style: ZyraTypography.titleMedium.copyWith(
                      color: ZyraColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        const _BellButton(),
        ShareButton(
          minutesStudied: totalMinutes,
          pointsEarned: totalPoints,
          sessionType: 'focus',
        ),
      ],
    );
  }
}

/// Bell that opens the treats inbox, with a badge for unread ones.
class _BellButton extends ConsumerWidget {
  const _BellButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unseen = ref.watch(unseenGiftCountProvider);
    return IconButton(
      tooltip: AppLocalizations.of(context).notifications,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      ),
      icon: Badge(
        isLabelVisible: unseen > 0,
        label: Text('$unseen'),
        child: const Icon(
          Icons.notifications_none_rounded,
          color: ZyraColors.primary,
        ),
      ),
    );
  }
}

class _MotivationCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _MotivationCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ZyraColors.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: ZyraColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.dailyMotivation,
                style: ZyraTypography.titleMedium.copyWith(
                  color: ZyraColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.motivationText,
            style: ZyraTypography.bodyMedium.copyWith(
              color: ZyraColors.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
