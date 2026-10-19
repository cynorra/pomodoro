import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/global_exception_handler.dart';

class ShareService {
  static Future<void> shareToWhatsApp({
    required String text,
    File? image,
  }) async {
    try {
      if (image != null) {
        await Share.shareXFiles(
          [XFile(image.path)],
          text: text,
        );
      } else {
        final whatsappUri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        } else {
          await Share.share(text);
        }
      }
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'WhatsApp share failed');
      await Share.share(text);
    }
  }

  static Future<void> shareToInstagramStories({
    required File imageFile,
    required String caption,
    String? backgroundTopColor,
    String? backgroundBottomColor,
  }) async {
    try {
      if (Platform.isIOS) {
        final uri = Uri.parse('instagram-stories://share');
        if (await canLaunchUrl(uri)) {
          await Share.shareXFiles([XFile(imageFile.path)]);
        } else {
          await launchUrl(
            Uri.parse('https://apps.apple.com/app/instagram/id389801252'),
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        await Share.shareXFiles(
          [XFile(imageFile.path)],
          text: caption,
        );
      }
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Instagram share failed');
    }
  }

  static Future<void> shareToTikTok({
    required File videoOrImage,
    required String text,
    required String subject,
  }) async {
    try {
      await Share.shareXFiles(
        [XFile(videoOrImage.path)],
        text: text,
        subject: subject,
      );
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'TikTok share failed');
    }
  }

  static Future<void> shareGeneral({
    required String text,
    List<File>? images,
    String? subject,
  }) async {
    try {
      if (images != null && images.isNotEmpty) {
        await Share.shareXFiles(
          images.map((f) => XFile(f.path)).toList(),
          text: text,
          subject: subject,
        );
      } else {
        await Share.share(text, subject: subject);
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
