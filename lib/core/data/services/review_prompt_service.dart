import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewPromptService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'app_review_prompt_state_v1';
  static const _packageId = 'com.cynora.studycafe.pomodoro';
  static const _minLaunches = 3;
  static const _maxPrompts = 2;
  static const _cooldownMs = 21 * 24 * 60 * 60 * 1000;

  static bool _checkedThisSession = false;

  static Future<Map<String, dynamic>> _load() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  static Future<void> _save(Map<String, dynamic> state) async {
    try {
      await _storage.write(key: _key, value: jsonEncode(state));
    } catch (_) {}
  }

  static Future<void> maybePrompt(BuildContext context) async {
    if (_checkedThisSession) return;
    _checkedThisSession = true;

    final state = await _load();
    final launches = (state['launches'] as int? ?? 0) + 1;
    state['launches'] = launches;
    await _save(state);

    final hasRated = state['has_rated'] == true;
    final neverAsk = state['never_ask'] == true;
    final promptCount = state['prompt_count'] as int? ?? 0;
    final lastPromptAt = state['last_prompt_at'] as int? ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (hasRated || neverAsk) return;
    if (launches < _minLaunches) return;
    if (promptCount >= _maxPrompts) return;
    if (lastPromptAt > 0 && (now - lastPromptAt) < _cooldownMs) return;

    await Future<void>.delayed(const Duration(seconds: 6));
    if (!context.mounted) return;

    final isTr = Localizations.localeOf(context).languageCode.toLowerCase() == 'tr';

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isTr ? 'StudyCafe\'yi Beğeniyor musunuz?' : 'Enjoying StudyCafe?'),
        content: Text(
          isTr
              ? 'StudyCafe\'yi geliştirmemize destek olmak için Google Play\'de değerlendirmenizi paylaşabilirsiniz.'
              : 'Your review on Google Play helps us improve StudyCafe for everyone.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              state['never_ask'] = true;
              state['last_prompt_at'] = DateTime.now().millisecondsSinceEpoch;
              await _save(state);
            },
            child: Text(isTr ? 'Bir Daha Gösterme' : 'Don\'t Ask Again'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              state['prompt_count'] = promptCount + 1;
              state['last_prompt_at'] = DateTime.now().millisecondsSinceEpoch;
              await _save(state);
            },
            child: Text(isTr ? 'Şimdi Değil' : 'Not Now'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openPlayStoreReview();
            },
            child: Text(isTr ? 'Değerlendir' : 'Rate App'),
          ),
        ],
      ),
    );
  }

  static Future<void> openPlayStoreReview() async {
    final state = await _load();
    state['has_rated'] = true;
    state['last_prompt_at'] = DateTime.now().millisecondsSinceEpoch;
    await _save(state);

    final marketUri = Uri.parse('market://details?id=$_packageId');
    final webUri = Uri.parse('https://play.google.com/store/apps/details?id=$_packageId');
    try {
      if (!await launchUrl(marketUri, mode: LaunchMode.externalApplication)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }
}
