import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/jelly_button.dart';
import '../../../core/data/models/auth_status.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';
import '../../../l10n/l10n_extension.dart';
import 'auth_error_text.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.createAccount,
          style: ZyraTypography.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  inputFormatters: [LengthLimitingTextInputFormatter(30)],
                  decoration: InputDecoration(
                    labelText: l10n.displayName,
                    prefixIcon: const Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.nameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    helperText: context.l10n.passwordHint,
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() => _agreedToTerms = value ?? false);
                      },
                      activeColor: ZyraColors.primary,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _agreedToTerms = !_agreedToTerms);
                        },
                        child: Text(
                          l10n.agreeToTerms,
                          style: ZyraTypography.bodyMedium.copyWith(
                            color: ZyraColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                  onPressed: _agreedToTerms &&
                          authState.status != AuthStatus.loading
                      ? _handleSignup
                      : null,
                  label: authState.status == AuthStatus.loading
                      ? context.l10n.signingUp
                      : (l10n.signUp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignup() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    ref.read(authProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
  }
}
