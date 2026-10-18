import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/jelly_button.dart';
import '../../../core/data/services/auth_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/auth_notifier.dart';

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
          l10n?.deleteAccount ?? 'Hesabı Sil',
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
                'Hesabını silmek istediğinden emin misin?',
                style: ZyraTypography.headlineMedium.copyWith(
                  color: ZyraColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Bu işlem geri alınamaz. Tüm verilerin kalıcı olarak silinecek:',
                style: ZyraTypography.bodyMedium.copyWith(
                  color: ZyraColors.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const _DeletionItem(
                icon: Icons.data_usage_outlined,
                text: 'Tüm çalışma verilerin',
              ),
              const _DeletionItem(
                icon: Icons.emoji_events_outlined,
                text: 'Kazandığın rozetler ve puanlar',
              ),
              const _DeletionItem(
                icon: Icons.local_fire_department_outlined,
                text: 'Streak kayıtların',
              ),
              const _DeletionItem(
                icon: Icons.coffee_outlined,
                text: 'Sanal kafe envanterin',
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
                      'Hesabımın kalıcı olarak silinmesini onaylıyorum',
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
                    ? 'Hesap siliniyor...'
                    : 'Hesabı Kalıcı Olarak Sil',
                backgroundColor: _confirmed
                    ? Colors.redAccent
                    : Colors.redAccent.withOpacity(0.5),
                textColor: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'Buton çalışmıyorsa web üzerinden silebilirsin:',
                style: ZyraTypography.bodyMedium.copyWith(
                  color: ZyraColors.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  final uri = Uri.parse(AuthService.accountDeletionWebUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: Text(
                  AuthService.accountDeletionWebUrl,
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
      setState(() => _isLoading = false);

      final credentials = await _showReAuthDialog();
      if (credentials == null) return;

      setState(() => _isLoading = true);
      result = await ref.read(authProvider.notifier).deleteAccount(
            email: credentials.$1,
            password: credentials.$2,
          );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hesabın başarıyla silindi'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Hesap silinemedi'),
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
        title: const Text('Güvenlik Doğrulaması'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hesap silme için şifrenizi tekrar girin'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Şifre'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              final email = emailController.text.trim();
              final password = passwordController.text;
              if (email.isEmpty || password.isEmpty) return;
              Navigator.pop(dialogContext, (email, password));
            },
            child: const Text('Doğrula'),
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
