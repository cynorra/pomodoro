import 'package:url_launcher/url_launcher.dart';
import 'global_exception_handler.dart';

/// Opens [url] in the external browser. Never throws; returns false on failure.
Future<bool> openExternalUrl(String url) async {
  try {
    return await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (e, stack) {
    GlobalExceptionHandler.logError(e, stack, 'Open URL failed');
    return false;
  }
}
