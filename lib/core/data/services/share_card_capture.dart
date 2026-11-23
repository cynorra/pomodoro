import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/global_exception_handler.dart';

class ShareCardCapture {
  static Future<File?> capture(GlobalKey boundaryKey,
      {double pixelRatio = 3.0}) async {
    try {
      final context = boundaryKey.currentContext;
      if (context == null) return null;

      final renderObject = context.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) return null;

      final image = await renderObject.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData == null) return null;

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/studycafe_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file;
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Share capture failed');
      return null;
    }
  }
}
