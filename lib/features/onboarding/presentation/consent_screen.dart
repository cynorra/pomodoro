import 'package:flutter/material.dart';
import '../../../core/data/services/auth_service.dart';
import '../../../core/data/services/privacy_consent_service.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/utils/url_opener.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Asks, once, whether anonymous analytics and crash reports may be collected.
/// Both answers are equally prominent and both lead on into the app.
class ConsentScreen extends StatelessWidget {
  final VoidCallback onDone;

  /// Stores the choice; replaceable so the screen can be tested without the
  /// Firebase and secure-storage plugins.
  final Future<void> Function(bool granted) save;

  const ConsentScreen({
    super.key,
    required this.onDone,
    this.save = PrivacyConsentService.save,
  });

  Future<void> _choose(bool granted) async {
    await save(granted);
    onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      foregroundColor: ZyraColors.primary,
      side: const BorderSide(color: ZyraColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );

    return Scaffold(
      backgroundColor: ZyraColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.privacy_tip_outlined,
                  size: 56, color: ZyraColors.primary),
              const SizedBox(height: 20),
              Text(
                l10n.consentTitle,
                textAlign: TextAlign.center,
                style: ZyraTypography.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(l10n.consentBody, style: ZyraTypography.bodyMedium),
              const SizedBox(height: 12),
              Text(
                l10n.consentFootnote,
                style: ZyraTypography.labelSmall.copyWith(
                  color: ZyraColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              TextButton(
                onPressed: () => openExternalUrl(
                    AuthService.privacyPolicyUrl(l10n.localeName)),
                child: Text(l10n.consentPrivacyLink),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: buttonStyle,
                onPressed: () => _choose(true),
                child: Text(l10n.consentAccept),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: buttonStyle,
                onPressed: () => _choose(false),
                child: Text(l10n.consentDecline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
