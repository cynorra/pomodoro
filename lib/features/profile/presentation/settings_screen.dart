import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/data/services/notification_service.dart';
import '../../../core/data/services/reminder_service.dart';
import '../../../core/data/services/privacy_consent_service.dart';
import '../../../core/data/services/data_export_service.dart';
import '../../../core/data/services/local_data_service.dart';
import '../../social/presentation/social_providers.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../core/data/state/locale_notifier.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/data/services/sfx_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: ZyraColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settings, style: ZyraTypography.titleLarge),
            Text(
              'MASA & DUYUSAL ATÖLYE',
              style: ZyraTypography.sectionLabel.copyWith(
                fontSize: 10,
                color: ZyraColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: l10n.settings.toUpperCase()),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.language_rounded,
              title: l10n.language,
              trailing: DropdownButton<Locale>(
                value: _isValidLocale(currentLocale)
                    ? currentLocale
                    : const Locale('en'),
                dropdownColor: ZyraColors.surfaceElevated,
                underline: const SizedBox.shrink(),
                style: ZyraTypography.dataMono.copyWith(
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
            const _ReminderTile(),
            const SizedBox(height: 20),
            const _SectionHeader(title: 'AKUSTİK & DOKUNSAL ATÖLYE'),
            const SizedBox(height: 8),
            const _SfxTile(),
            const SizedBox(height: 12),
            const _HapticStudioCard(),
            const _FocusStatusTile(),
            const SizedBox(height: 20),
            const _SectionHeader(title: 'GİZLİLİK & VERİ'),
            const SizedBox(height: 8),
            const _AnalyticsConsentTile(),
            const _AdPrivacyTile(),
            const _ExportDataTile(),
            const _ClearCacheTile(),
          ],
        ),
      ),
    );
  }

  bool _isValidLocale(Locale locale) {
    return locale.languageCode == 'tr' || locale.languageCode == 'en';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: ZyraTypography.sectionLabel.copyWith(
          color: ZyraColors.primary,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

/// Interactive Haptic & Sound Preview Studio from Nocturne Atelier design.
class _HapticStudioCard extends StatefulWidget {
  const _HapticStudioCard();

  @override
  State<_HapticStudioCard> createState() => _HapticStudioCardState();
}

class _HapticStudioCardState extends State<_HapticStudioCard> {
  int _intensityIndex = 2; // 0: Off, 1: Light, 2: Balanced, 3: Strong

  static const _levels = [
    ('Kapalı', 'Sessiz ekran'),
    ('Hafif', 'İnce vuruş'),
    ('Dengeli', 'Ceviz tıkırtı'),
    ('Güçlü', 'Mühür darbesi'),
  ];

  void _triggerPreview() {
    switch (_intensityIndex) {
      case 1:
        HapticFeedback.selectionClick();
        break;
      case 2:
        HapticFeedback.mediumImpact();
        SfxService.play(Sfx.coin);
        break;
      case 3:
        HapticFeedback.heavyImpact();
        SfxService.play(Sfx.purchase);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.vibration_rounded,
                color: ZyraColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Haptic Titreşim Yoğunluğu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZyraTypography.titleMedium.copyWith(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              NocturnePillBadge(
                label: _levels[_intensityIndex].$1,
                textColor: ZyraColors.primaryBright,
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.0,
            children: [
              for (var i = 0; i < _levels.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() => _intensityIndex = i);
                    _triggerPreview();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _intensityIndex == i
                          ? ZyraColors.primary
                          : ZyraColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _intensityIndex == i
                            ? ZyraColors.primary
                            : ZyraColors.hairline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _levels[i].$1,
                          style: ZyraTypography.labelLarge.copyWith(
                            fontSize: 13,
                            color: _intensityIndex == i
                                ? ZyraColors.onPrimary
                                : ZyraColors.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _levels[i].$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ZyraTypography.labelSmall.copyWith(
                            fontSize: 10,
                            color: _intensityIndex == i
                                ? ZyraColors.onPrimary.withValues(alpha: 0.78)
                                : ZyraColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _triggerPreview,
              icon: const Icon(Icons.touch_app_outlined, size: 17),
              label: const Text('Titreşimi & Sesi Test Et'),
            ),
          ),
        ],
      ),
    );
  }
}

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
                color: ZyraColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
            style: ZyraTypography.dataMono.copyWith(
              color: on ? ZyraColors.secondaryBright : ZyraColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReminderTile extends StatefulWidget {
  const _ReminderTile();

  @override
  State<_ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<_ReminderTile> {
  ReminderSettings? _settings;

  @override
  void initState() {
    super.initState();
    ReminderService.load().then((s) {
      if (mounted) setState(() => _settings = s);
    });
  }

  Future<void> _save(ReminderSettings next) async {
    setState(() => _settings = next);
    if (next.enabled) await NotificationService.requestPermissionIfNeeded();
    await ReminderService.save(next);
  }

  Future<void> _pickTime(ReminderSettings current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked == null) return;
    await _save(ReminderSettings(
      enabled: true,
      hour: picked.hour,
      minute: picked.minute,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = _settings ?? const ReminderSettings();
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: current.hour, minute: current.minute),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsTile(
            icon: Icons.alarm_rounded,
            title: l10n.reminderTitle,
            trailing: Switch(
              value: current.enabled,
              onChanged: _settings == null
                  ? null
                  : (value) => _save(ReminderSettings(
                        enabled: value,
                        hour: current.hour,
                        minute: current.minute,
                      )),
            ),
          ),
          if (current.enabled)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _pickTime(current),
                icon: const Icon(Icons.schedule_rounded, size: 18),
                label: Text(l10n.reminderAt(time)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
            child: Text(
              l10n.reminderHelp,
              style: ZyraTypography.labelSmall.copyWith(
                color: ZyraColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: ZyraColors.primary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: ZyraTypography.titleMedium.copyWith(fontSize: 14),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _AnalyticsConsentTile extends StatefulWidget {
  const _AnalyticsConsentTile();

  @override
  State<_AnalyticsConsentTile> createState() => _AnalyticsConsentTileState();
}

class _AnalyticsConsentTileState extends State<_AnalyticsConsentTile> {
  bool _on = false;

  @override
  void initState() {
    super.initState();
    PrivacyConsentService.read().then((v) {
      if (mounted) setState(() => _on = v == true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsTile(
          icon: Icons.insights_outlined,
          title: l10n.analyticsConsentTitle,
          trailing: Switch(
            value: _on,
            onChanged: (value) async {
              setState(() => _on = value);
              await PrivacyConsentService.save(value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
          child: Text(
            l10n.analyticsConsentHelp,
            style: ZyraTypography.labelSmall.copyWith(
              color: ZyraColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExportDataTile extends StatelessWidget {
  const _ExportDataTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsTile(
            icon: Icons.download_outlined,
            title: l10n.exportData,
            trailing: IconButton(
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: ZyraColors.textSecondary,
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await DataExportService.exportAndShare();
                } catch (_) {
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.exportDataFailed)),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: Text(
              l10n.exportDataHelp,
              style: ZyraTypography.labelSmall.copyWith(
                color: ZyraColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClearCacheTile extends StatelessWidget {
  const _ClearCacheTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsTile(
            icon: Icons.cleaning_services_outlined,
            title: l10n.clearCache,
            trailing: IconButton(
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: ZyraColors.textSecondary,
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await LocalDataService.clearCache();
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.cacheCleared)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
            child: Text(
              l10n.clearCacheHelp,
              style: ZyraTypography.labelSmall.copyWith(
                color: ZyraColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SfxTile extends StatefulWidget {
  const _SfxTile();

  @override
  State<_SfxTile> createState() => _SfxTileState();
}

class _SfxTileState extends State<_SfxTile> {
  bool _on = true;

  @override
  void initState() {
    super.initState();
    SfxService.isEnabled().then((v) {
      if (mounted) setState(() => _on = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SettingsTile(
      icon: Icons.volume_up_outlined,
      title: l10n.sfxTitle,
      trailing: Switch(
        value: _on,
        onChanged: (value) {
          setState(() => _on = value);
          SfxService.setEnabled(value);
          if (value) SfxService.play(Sfx.coin);
        },
      ),
    );
  }
}
