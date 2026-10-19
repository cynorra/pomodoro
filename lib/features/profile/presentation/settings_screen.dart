import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _SettingsTile(
              icon: Icons.language_rounded,
              title: l10n.language,
              trailing: DropdownButton<Locale>(
                value: _isValidLocale(currentLocale) ? currentLocale : const Locale('tr'),
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
          ],
        ),
      ),
    );
  }
  
  bool _isValidLocale(Locale locale) {
    return locale.languageCode == 'tr' || locale.languageCode == 'en';
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
