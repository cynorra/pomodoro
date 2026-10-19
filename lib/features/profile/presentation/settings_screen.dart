import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/data/services/notification_service.dart';
import '../../social/presentation/social_providers.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/data/state/locale_notifier.dart';
import '../../../l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.settings,
          style: ZyraTypography.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _SettingsTile(
              icon: Icons.language_rounded,
              title: l10n.language,
              trailing: DropdownButton<Locale>(
                value: _isValidLocale(currentLocale)
                    ? currentLocale
                    : const Locale('en'),
                dropdownColor: ZyraColors.surface,
                underline: const SizedBox.shrink(),
                style: ZyraTypography.titleMedium.copyWith(
                  color: ZyraColors.primary,
                ),
                items: [
                  DropdownMenuItem(
                    value: const Locale('tr'),
                    child: Text(l10n.turkish),
                  ),
                  DropdownMenuItem(
                    value: const Locale('en'),
                    child: Text(l10n.english),
                  ),
                ],
                onChanged: (locale) {
                  if (locale != null) {
                    ref.read(localeProvider.notifier).setLocale(locale);
                  }
                },
              ),
            ),
            const _NotificationsTile(),
            const _FocusStatusTile(),
            const _AdPrivacyTile(),
          ],
        ),
      ),
    );
  }

  bool _isValidLocale(Locale locale) {
    return locale.languageCode == 'tr' || locale.languageCode == 'en';
  }
}

/// Opt-in switch: while on, friends can see this user is focusing and send
/// treats. Off by default because it shares the display name and session end.
class _FocusStatusTile extends ConsumerWidget {
  const _FocusStatusTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final on = ref.watch(focusStatusProvider);
    final signedIn = ref.watch(signedInProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsTile(
            icon: Icons.local_cafe_outlined,
            title: l10n.focusStatusTitle,
            trailing: Switch(
              value: on,
              onChanged: (value) {
                if (value && !signedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.focusStatusSignIn)),
                  );
                  return;
                }
                ref.read(focusStatusProvider.notifier).set(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: Text(
              l10n.focusStatusHelp,
              style: ZyraTypography.labelSmall.copyWith(
                color: ZyraColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows whether session-end notifications are allowed and lets the user ask
/// for the permission again. Android only lets the app ask while the system
/// has not blocked it, so when it stays off the dialog explains where to turn
/// it on.
class _NotificationsTile extends StatefulWidget {
  const _NotificationsTile();

  @override
  State<_NotificationsTile> createState() => _NotificationsTileState();
}

class _NotificationsTileState extends State<_NotificationsTile> {
  bool? _enabled;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final enabled = await NotificationService.notificationsEnabled();
    if (mounted) setState(() => _enabled = enabled);
  }

  Future<void> _onTap() async {
    final l10n = AppLocalizations.of(context);
    if (_enabled == true) {
      await _showHelp(l10n.notificationsOnHelp);
      return;
    }
    await NotificationService.requestPermissionIfNeeded();
    await _refresh();
    if (_enabled != true && mounted) {
      await _showHelp(l10n.notificationsOffHelp);
    }
  }

  Future<void> _showHelp(String text) {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ZyraColors.surface,
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final on = _enabled == true;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: _SettingsTile(
        icon: on
            ? Icons.notifications_active_outlined
            : Icons.notifications_off_outlined,
        title: l10n.notifications,
        trailing: TextButton(
          onPressed: _enabled == null ? null : _onTap,
          child: Text(
            on ? l10n.notificationsOn : l10n.notificationsOff,
            style: ZyraTypography.titleMedium.copyWith(
              color: on
                  ? ZyraColors.primary
                  : ZyraColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

/// Entry point to Google's ad-consent form; only shown where the consent
/// framework says users must be able to revisit their choice.
class _AdPrivacyTile extends StatelessWidget {
  const _AdPrivacyTile();

  Future<bool> _required() async {
    try {
      return await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<bool>(
      future: _required(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.adPrivacySettings,
            trailing: IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () => ConsentForm.showPrivacyOptionsForm((_) {}),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ZyraColors.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: ZyraColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: ZyraTypography.titleMedium.copyWith(
                color: ZyraColors.onSurface,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
