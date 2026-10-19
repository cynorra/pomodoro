import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/jelly_button.dart';
import '../../../core/data/services/auth_service.dart';
import '../../../core/data/models/auth_status.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';
import 'signup_screen.dart';
import '../../../l10n/l10n_extension.dart';
import 'auth_error_text.dart';
import '../../../core/ui/responsive.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    return Scaffold(
      backgroundColor: ZyraColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.isShort ? 16 : 60),
                Container(
                  width: context.scaled(100),
                  height: context.scaled(100),
                  decoration: BoxDecoration(
                    color: ZyraColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.timer_rounded,
                    color: ZyraColors.onPrimary,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Study Cafe',
                  style: ZyraTypography.headlineLarge.copyWith(
                    color: ZyraColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.appTitle,
                  style: ZyraTypography.bodyMedium.copyWith(
                    color: ZyraColors.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.emailRequired;
                    }
                    if (!value.contains('@')) {
                      return context.l10n.emailInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.passwordRequired;
                    }
                    if (value.length < 6) {
                      return context.l10n.passwordTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showPasswordResetDialog,
                    child: Text(
                      l10n.forgotPassword,
                      style: ZyraTypography.labelLarge.copyWith(
                        color: ZyraColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (authState.status == AuthStatus.error &&
                    authState.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      authErrorText(context.l10n, authState.errorMessage),
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                JellyButton(
                  onPressed: authState.status == AuthStatus.loading
                      ? null
                      : _handleLogin,
                  label: authState.status == AuthStatus.loading
                      ? context.l10n.signingIn
                      : (l10n.login),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        l10n.orDivider,
                        style: ZyraTypography.labelSmall.copyWith(
                          color: ZyraColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: authState.status == AuthStatus.loading
                      ? null
                      : () => ref.read(authProvider.notifier).signInWithGoogle(),
                  icon: const Icon(Icons.account_circle_outlined),
                  label: Text(l10n.continueWithGoogle),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: Text(
                    l10n.noAccountSignup,
                    style: ZyraTypography.labelLarge.copyWith(
                      color: ZyraColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  child: Text(
                    context.l10n.continueAsGuest,
                    style: ZyraTypography.labelLarge.copyWith(
                      color: ZyraColors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => _openUrl(AuthService.privacyPolicyUrl),
                      child: Text(
                        l10n.privacyPolicy,
                        style: ZyraTypography.labelSmall.copyWith(
                          color: ZyraColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () => _openUrl(AuthService.termsOfServiceUrl),
                      child: Text(
                        l10n.termsOfService,
                        style: ZyraTypography.labelSmall.copyWith(
                          color: ZyraColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _handleLogin() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    ref.read(authProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _showPasswordResetDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ZyraColors.surface,
        title: Text(
          context.l10n.resetPasswordTitle,
          style: ZyraTypography.titleMedium.copyWith(
            color: ZyraColors.onSurface,
          ),
        ),
        content: TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: context.l10n.yourEmailAddress),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final result = await AuthService.sendPasswordReset(
                emailController.text.trim(),
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result.isSuccess
                        ? context.l10n.resetEmailSent
                        : authErrorText(context.l10n, result.errorMessage),
                  ),
                ),
              );
            },
            child: Text(context.l10n.send),
          ),
        ],
      ),
    );
  }
}

