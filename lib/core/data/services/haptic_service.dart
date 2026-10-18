import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  static Future<void> sessionComplete() async {
    try {
      if (Platform.isAndroid) {
        if (await Vibration.hasVibrator() ?? false) {
          await Vibration.vibrate(pattern: [0, 100, 50, 100]);
        }
      } else {
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Ignore
    }
  }

  static Future<void> purchaseSuccess() async {
    try {
      if (Platform.isAndroid) {
        if (await Vibration.hasVibrator() ?? false) {
          await Vibration.vibrate(duration: 50);
        }
      } else {
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Ignore
    }
  }

  static Future<void> insufficientPoints() async {
    try {
      if (Platform.isAndroid) {
        if (await Vibration.hasVibrator() ?? false) {
          await Vibration.vibrate(pattern: [0, 200]);
        }
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Ignore
    }
  }
}
