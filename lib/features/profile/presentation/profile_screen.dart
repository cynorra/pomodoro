import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../core/data/models/auth_status.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/data/state/streak_notifier.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../auth/presentation/login_screen.dart';
import '../../leaderboard/presentation/leaderboard_screen.dart';
import 'account_deletion_screen.dart';
import 'settings_screen.dart';
import 'level_card.dart';
import '../../room/presentation/room_screen.dart';
import '../../achievements/presentation/achievements_screen.dart';
import '../../help/presentation/help_screen.dart';
import '../../social/presentation/invite_friends_screen.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../core/utils/url_opener.dart';
import '../../../core/data/services/auth_service.dart';
import '../../monetization/presentation/native_ad_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final streakAsync = ref.watch(streakProvider);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: ZyraColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NOCTURNE',
              style: ZyraTypography.titleLarge.copyWith(
                fontSize: 18,
                letterSpacing: 1.8,
              ),
            ),
            Text(
              l10n.profile.toUpperCase(),
              style: ZyraTypography.sectionLabel.copyWith(
                fontSize: 10,
                color: ZyraColors.textTertiary,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.tune_rounded,
              color: ZyraColors.textSecondary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          children: [
            _ProfileCard(
              displayName: authState.userDisplayName ?? context.l10n.guestName,
              email: authState.userEmail ?? context.l10n.notSignedIn,
              totalPoints: userState.totalPoints,
              isAuthenticated: authState.status == AuthStatus.authenticated,
            ),
            const SizedBox(height: 14),
            const LevelCard(),
            const SizedBox(height: 14),
            streakAsync.when(
              data: (streak) => _StatsGrid(
                totalPoints: userState.totalPoints,
                totalMinutes: userState.totalStudyMinutes,
                currentStreak: streak,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 14),
            const NativeAdCard(),
            const SizedBox(height: 14),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.leaderboard_outlined,
                    title: context.l10n.leaderboard,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen(),
                      ),
                    ),
                  ),
                  const Divider(indent: 52),
                  _MenuItem(
                    icon: Icons.emoji_events_outlined,
                    title: l10n.achievements,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AchievementsScreen(),
                      ),
                    ),
                  ),
                  const Divider(indent: 52),
                  _MenuItem(
                    icon: Icons.groups_outlined,
                    title: l10n.roomTitle,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RoomScreen(),
                      ),
                    ),
                  ),
                  const Divider(indent: 52),
                  _MenuItem(
                    icon: Icons.person_add_alt_1_outlined,
                    title: l10n.inviteFriends,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InviteFriendsScreen(),
                      ),
                    ),
                  ),
                  const Divider(indent: 52),
                  _MenuItem(
                    icon: Icons.tune_rounded,
                    title: l10n.settings,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    title: l10n.help,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpScreen(),
                      ),
                    ),
                  ),
                  const Divider(indent: 52),
                  _MenuItem(
                    icon: Icons.policy_outlined,
                    title: l10n.privacyPolicy,
                    onTap: () => openExternalUrl(
                      AuthService.privacyPolicyUrl(l10n.localeName),
                    ),
                  ),
                  const Divider(indent: 52),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    title: l10n.termsOfService,
                    onTap: () => openExternalUrl(
                      AuthService.termsOfServiceUrl(l10n.localeName),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  if (authState.status == AuthStatus.authenticated) ...[
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      title: l10n.logout,
                      textColor: ZyraColors.error,
                      onTap: () => _showLogoutDialog(context, ref),
                    ),
                    const Divider(indent: 52),
                    _MenuItem(
                      icon: Icons.delete_outline_rounded,
                      title: l10n.deleteAccount,
                      textColor: ZyraColors.error,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountDeletionScreen(),
                        ),
                      ),
                    ),
                  ] else ...[
                    _MenuItem(
                      icon: Icons.login_rounded,
                      title: context.l10n.signInOrSignUp,
                      textColor: ZyraColors.primary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              '“Gece çalışanların sakin limanı.”',
              style: ZyraTypography.editorialItalic.copyWith(
                fontSize: 14,
                color: ZyraColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NOCTURNE ATELIER',
              style: ZyraTypography.dataMono.copyWith(
                fontSize: 10,
                color: ZyraColors.textTertiary,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ZyraColors.surface,
        title: Text(context.l10n.logout),
        content: Text(context.l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authProvider.notifier).signOut();
            },
            child: Text(
              context.l10n.logout,
              style: const TextStyle(color: ZyraColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String displayName;
  final String email;
  final int totalPoints;
  final bool isAuthenticated;

  const _ProfileCard({
    required this.displayName,
    required this.email,
    required this.totalPoints,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    final initials = displayName.trim().isNotEmpty
        ? displayName.trim().characters.take(2).toString().toUpperCase()
        : 'NA';

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: ZyraColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ZyraColors.primary.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: ZyraTypography.headlineMedium.copyWith(
                    color: ZyraColors.primaryBright,
                    fontSize: 22,
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isAuthenticated
                        ? ZyraColors.secondary
                        : ZyraColors.textTertiary,
                    shape: BoxShape.circle,
                    border: Border.all(color: ZyraColors.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: ZyraTypography.headlineMedium.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: ZyraTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: ZyraColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ZyraColors.hairline),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.toll_outlined,
                  color: ZyraColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  context.l10n.points,
                  style: ZyraTypography.bodySmall.copyWith(
                    color: ZyraColors.onBackground,
                  ),
                ),
                const Spacer(),
                Text(
                  '$totalPoints',
                  style: ZyraTypography.dataMono.copyWith(
                    color: ZyraColors.primaryBright,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int totalPoints;
  final int totalMinutes;
  final int currentStreak;

  const _StatsGrid({
    required this.totalPoints,
    required this.totalMinutes,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: context.l10n.hours.toUpperCase(),
            value: (totalMinutes / 60).toStringAsFixed(1),
            color: ZyraColors.onBackground,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: context.l10n.days.toUpperCase(),
            value: '$currentStreak',
            color: ZyraColors.secondaryBright,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: context.l10n.points.toUpperCase(),
            value: '$totalPoints',
            color: ZyraColors.primary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ZyraTypography.sectionLabel.copyWith(
              fontSize: 10,
              color: ZyraColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: ZyraTypography.dataMonoLarge.copyWith(
              fontSize: 22,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: textColor ?? ZyraColors.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: ZyraTypography.titleMedium.copyWith(
                  fontSize: 14,
                  color: textColor ?? ZyraColors.onBackground,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: textColor ?? ZyraColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
