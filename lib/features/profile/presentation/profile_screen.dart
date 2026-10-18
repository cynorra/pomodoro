import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/data/models/auth_status.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/data/state/streak_notifier.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../leaderboard/presentation/leaderboard_screen.dart';
import 'account_deletion_screen.dart';
import 'settings_screen.dart';
import '../../achievements/presentation/achievements_screen.dart';
import '../../help/presentation/help_screen.dart';
import '../../social/presentation/invite_friends_screen.dart';

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.profile ?? 'Profil',
          style: ZyraTypography.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ProfileCard(
              displayName: authState.userDisplayName ?? 'Misafir',
              email: authState.userEmail ?? 'Giriş yapılmadı',
              isAuthenticated:
                  authState.status == AuthStatus.authenticated,
            ),
            const SizedBox(height: 16),
            streakAsync.when(
              data: (streak) => _StatsGrid(
                totalPoints: userState.totalPoints,
                totalMinutes: userState.totalStudyMinutes,
                currentStreak: streak,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            _MenuItem(
              icon: Icons.leaderboard_outlined,
              title: 'Global Sıralama',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LeaderboardScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _MenuItem(
              icon: Icons.emoji_events_outlined,
              title: l10n?.achievements ?? 'Başarılar',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AchievementsScreen(),
                  ),
                );
              },
            ),
            _MenuItem(
              icon: Icons.share_outlined,
              title: l10n?.inviteFriends ?? 'Arkadaş Davet Et',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InviteFriendsScreen(),
                  ),
                );
              },
            ),
            _MenuItem(
              icon: Icons.help_outline,
              title: l10n?.help ?? 'Yardım',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HelpScreen(),
                  ),
                );
              },
            ),
            _MenuItem(
              icon: Icons.policy_outlined,
              title: l10n?.privacyPolicy ?? 'Gizlilik Politikası',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.description_outlined,
              title: l10n?.termsOfService ?? 'Kullanım Şartları',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            if (authState.status == AuthStatus.authenticated) ...[
              _MenuItem(
                icon: Icons.logout,
                title: l10n?.logout ?? 'Çıkış Yap',
                textColor: Colors.redAccent,
                onTap: () => _showLogoutDialog(context, ref),
              ),
              const SizedBox(height: 8),
              _MenuItem(
                icon: Icons.delete_forever_outlined,
                title: l10n?.deleteAccount ?? 'Hesabı Sil',
                textColor: Colors.redAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AccountDeletionScreen(),
                    ),
                  );
                },
              ),
            ] else ...[
              _MenuItem(
                icon: Icons.login,
                title: 'Giriş Yap / Kayıt Ol',
                textColor: ZyraColors.primary,
                onTap: () {},
              ),
            ],
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
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authProvider.notifier).signOut();
            },
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.redAccent),
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
  final bool isAuthenticated;

  const _ProfileCard({
    required this.displayName,
    required this.email,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ZyraColors.primary.withOpacity(0.15),
            ZyraColors.secondary.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ZyraColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: ZyraColors.primary,
              borderRadius: BorderRadius.circular(35),
            ),
            child: const Icon(
              Icons.person,
              color: ZyraColors.onPrimary,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: ZyraTypography.titleMedium.copyWith(
                    color: ZyraColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: ZyraTypography.bodyMedium.copyWith(
                    color: ZyraColors.onSurface.withOpacity(0.6),
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
            icon: Icons.stars_rounded,
            value: '$totalPoints',
            label: 'Puan',
            color: ZyraColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            value: '${(totalMinutes / 60).toStringAsFixed(1)}',
            label: 'Saat',
            color: ZyraColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            value: '$currentStreak',
            label: 'Gün',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZyraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: ZyraTypography.headlineMedium.copyWith(color: color),
          ),
          Text(
            label,
            style: ZyraTypography.labelSmall.copyWith(
              color: ZyraColors.onSurface.withOpacity(0.6),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: ZyraColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: textColor ?? ZyraColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: ZyraTypography.titleMedium.copyWith(
                      color: textColor ?? ZyraColors.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: textColor ?? ZyraColors.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
