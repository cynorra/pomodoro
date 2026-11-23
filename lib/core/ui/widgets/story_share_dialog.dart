import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/social/presentation/social_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../data/services/share_card_capture.dart';
import '../../data/services/share_service.dart';
import '../zyra_theme.dart';

/// Shows [card] (a [StoryCard]) as a preview and shares it as a 1080x1920 image
/// together with [message] and a tracked store link (campaign = [campaign]).
/// [message] receives the link and returns the caption.
Future<void> showStoryShare(
  BuildContext context,
  WidgetRef ref, {
  required Widget card,
  required String campaign,
  required String Function(String link) message,
}) async {
  String? code;
  if (ref.read(signedInProvider)) {
    try {
      code = await ref.read(inviteCodeProvider.future);
    } catch (_) {
      code = null;
    }
  }
  if (!context.mounted) return;
  final link = ShareService.generateInviteLink(
    referralCode: code,
    campaign: campaign,
  );
  final key = GlobalKey();
  final l10n = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: ZyraColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FittedBox(
                child: RepaintBoundary(key: key, child: card),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.close),
                  ),
                ),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.share),
                    label: Text(l10n.shareAction),
                    onPressed: () async {
                      final file =
                          await ShareCardCapture.capture(key, pixelRatio: 4.0);
                      await ShareService.shareGeneral(
                        text: message(link),
                        images: file == null ? null : [file],
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
