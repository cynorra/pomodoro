import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/jelly_button.dart';
import '../../../core/data/services/auth_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/auth_error_text.dart';

class AccountDeletionScreen extends ConsumerStatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  ConsumerState<AccountDeletionScreen> createState() =>
      _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends ConsumerState<AccountDeletionScreen> {
  bool _confirmed = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.deleteAccount,
          style: ZyraTypography.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.deleteConfirmTitle,
                style: ZyraTypography.headlineMedium.copyWith(
                  color: ZyraColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.deleteIrreversible,
                style: ZyraTypography.bodyMedium.copyWith(
                  color: ZyraColors.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _DeletionItem(
                icon: Icons.data_usage_outlined,
                text: context.l10n.deleteItemStudy,
              ),
              _DeletionItem(
                icon: Icons.emoji_events_outlined,
                text: context.l10n.deleteItemBadges,
              ),
              _DeletionItem(
                icon: Icons.local_fire_department_outlined,
                text: context.l10n.deleteItemStreak,
              ),
              _DeletionItem(
                icon: Icons.coffee_outlined,
                text: context.l10n.deleteItemCafe,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Checkbox(
                    value: _confirmed,
                    onChanged: (value) {
                      setState(() => _confirmed = value ?? false);
                    },
                    activeColor: Colors.redAccent,
                  ),
                  Expanded(
                    child: Text(
                      context.l10n.deleteConfirmCheckbox,
                      style: ZyraTypography.bodyMedium.copyWith(
                        color: ZyraColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              JellyButton(
                onPressed: _confirmed && !_isLoading ? _handleDelete : null,
                label: _isLoading
                    ? context.l10n.deleting
                    : context.l10n.deleteAccountPermanently,
                backgroundColor: _confirmed
                    ? Colors.redAccent
                    : Colors.redAccent.withValues(alpha: 0.5),
                textColor: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.deleteWebHint,
                style: ZyraTypography.bodyMedium.copyWith(
                  color: ZyraColors.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  final uri = Uri.parse(AuthService.accountDeletionWebUrl(context.l10n.localeName));
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: Text(
                  AuthService.accountDeletionWebUrl(context.l10n.localeName),
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

  Future<void> _handleDelete() async {
    setState(() => _isLoading = true);

    var result = await ref.read(authProvider.notifier).deleteAccount();

    if (!result.isSuccess && result.errorMessage == 'requires-recent-login') {
      if (!mounted) return;
      if (AuthService.signedInWithGoogle) {
        result = await ref
            .read(authProvider.notifier)
            .deleteAccount(reauthWithGoogle: true);
      } else {
        setState(() => _isLoading = false);

        final credentials = await _showReAuthDialog();
        if (credentials == null) return;

        setState(() => _isLoading = true);
        result = await ref.read(authProvider.notifier).deleteAccount(
              email: credentials.$1,
              password: credentials.$2,
            );
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.accountDeleted),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authErrorText(context.l10n, result.errorMessage)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<(String, String)?> _showReAuthDialog() async {
    final emailController = TextEditingController(
      text: AuthService.currentUser?.email ?? '',
    );
    final passwordController = TextEditingController();

    return await showDialog<(String, String)>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ZyraColors.surface,
        title: Text(context.l10n.securityCheck),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.reauthPrompt),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: context.l10n.email),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: context.l10n.password),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final email = emailController.text.trim();
              final password = passwordController.text;
              if (email.isEmpty || password.isEmpty) return;
              Navigator.pop(dialogContext, (email, password));
            },
            child: Text(context.l10n.verify),
          ),
        ],
      ),
    );
  }
}

class _DeletionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DeletionItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.redAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: ZyraTypography.bodyMedium.copyWith(
                color: ZyraColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
