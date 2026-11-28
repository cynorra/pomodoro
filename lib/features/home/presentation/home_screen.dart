import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/data/state/streak_notifier.dart';
import '../../../core/data/state/achievement_event_notifier.dart';
import '../../../core/data/models/achievement.dart';
import '../../../core/ui/widgets/confetti_widget.dart';
import '../../../core/ui/widgets/glass_card.dart';
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
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: streakAsync.when(
                      data: (streak) => _TopHeader(
                        totalPoints: userState.totalPoints,
                        totalMinutes: userState.totalStudyMinutes,
                        currentStreak: streak,
                        l10n: l10n,
                      ),
                      loading: () => const SizedBox(height: 52),
                      error: (_, __) => const SizedBox(height: 52),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: const PomodoroWidget()
                        .animate()
                        .fadeIn(delay: 120.ms, duration: 480.ms),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: DailyGoalCard(),
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
                        .fadeIn(delay: 260.ms, duration: 480.ms),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: _MotivationCard(l10n: l10n)
                        .animate()
                        .fadeIn(delay: 360.ms, duration: 480.ms),
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
        child: GlassCard(
          elevated: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                achievement.iconEmoji,
                style: const TextStyle(fontSize: 56),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.achievementUnlocked,
                style: ZyraTypography.headlineMedium.copyWith(
                  color: ZyraColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isTr ? achievement.nameTr : achievement.nameEn,
                style: ZyraTypography.titleMedium.copyWith(
                  color: ZyraColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.awesome),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NOCTURNE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ZyraTypography.titleLarge.copyWith(
                  fontSize: 16,
                  letterSpacing: 1.4,
                  color: ZyraColors.onBackground,
                ),
              ),
              Text(
                l10n.navFocus.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ZyraTypography.sectionLabel.copyWith(
                  fontSize: 10,
                  color: ZyraColors.textTertiary,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        NocturnePillBadge(
          label: '$currentStreak',
          icon: Icons.local_fire_department_rounded,
          textColor: currentStreak > 0
              ? ZyraColors.primary
              : ZyraColors.textTertiary,
          backgroundColor: ZyraColors.surface,
        ),
        const SizedBox(width: 4),
        NocturnePillBadge(
          label: '$totalPoints',
          dotColor: ZyraColors.primary,
          textColor: ZyraColors.primaryBright,
          backgroundColor: ZyraColors.surface,
        ),
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
      visualDensity: VisualDensity.compact,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      ),
      icon: Badge(
        isLabelVisible: unseen > 0,
        backgroundColor: ZyraColors.primary,
        textColor: ZyraColors.onPrimary,
        label: Text('$unseen'),
        child: const Icon(
          Icons.notifications_none_rounded,
          color: ZyraColors.textSecondary,
          size: 22,
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
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_stories_outlined,
                color: ZyraColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.dailyMotivation.toUpperCase(),
                style: ZyraTypography.sectionLabel.copyWith(
                  color: ZyraColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '“${l10n.motivationText}”',
            style: ZyraTypography.editorialItalic.copyWith(
              fontSize: 17,
              color: ZyraColors.onBackground.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
