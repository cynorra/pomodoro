import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/global_exception_handler.dart';

class ShareService {
  static Future<void> _share({
    String? text,
    String? subject,
    List<File> files = const [],
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        files: files.isEmpty ? null : [for (final f in files) XFile(f.path)],
      ),
    );
  }

  /// Opens WhatsApp directly with [text]; falls back to the system share sheet
  /// when WhatsApp is not installed. Images cannot be attached to this link,
  /// use [shareGeneral] for the progress card.
  static Future<void> shareToWhatsApp({required String text}) async {
    try {
      final uri =
          Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await _share(text: text);
      }
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'WhatsApp share failed');
      await _share(text: text);
    }
  }

  static Future<void> shareGeneral({
    required String text,
    List<File>? images,
    String? subject,
  }) async {
    try {
      if (images != null && images.isNotEmpty) {
        await _share(text: text, subject: subject, files: images);
      } else {
        await _share(text: text, subject: subject);
      }
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'General share failed');
    }
  }

  static String generateInviteLink({String? referralCode}) {
    // Firebase Dynamic Links is shut down, so invites point straight at the
    // store listing; Play's `referrer` parameter carries the code.
    final base = getAppStoreLink();
    if (referralCode != null) {
      return '$base&referrer=${Uri.encodeComponent('ref=$referralCode')}';
    }
    return base;
  }

  static String getAppStoreLink() {
    if (Platform.isIOS) {
      return 'https://apps.apple.com/app/cynora-focus/id0000000000';
    }
    return 'https://play.google.com/store/apps/details?id=com.cynora.studycafe.pomodoro';
  }
}
