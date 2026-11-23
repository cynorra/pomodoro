import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../utils/global_exception_handler.dart';

/// Short feedback sounds (not the ambient study loops). All files are original
/// recordings synthesised for the app and live in assets/fx/.
enum Sfx {
  /// A focus session finished.
  complete('fx_complete.wav'),

  /// Points were paid out.
  coin('fx_coin.wav'),

  /// Something was bought in the cafe.
  purchase('fx_purchase.wav'),

  /// A break is over.
  breakEnd('fx_break_end.wav');

  const Sfx(this.file);
  final String file;
}

class SfxService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'sfx_enabled';
  static bool _enabled = true;
  static bool _loaded = false;

  static Future<bool> isEnabled() async {
    if (!_loaded) {
      try {
        _enabled = (await _storage.read(key: _key)) != 'false';
      } catch (_) {
        _enabled = true;
      }
      _loaded = true;
    }
    return _enabled;
  }

  static Future<void> setEnabled(bool value) async {
    _enabled = value;
    _loaded = true;
    try {
      await _storage.write(key: _key, value: value ? 'true' : 'false');
    } catch (_) {}
  }

  /// Plays [sfx] once, mixed over the ambient loop (no audio-focus grab, so rain
  /// or fireplace keep playing). Never throws.
  static Future<void> play(Sfx sfx) async {
    try {
      if (!await isEnabled()) return;
      final player = AudioPlayer();
      await player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            audioFocus: AndroidAudioFocus.none,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
          ),
        ),
      );
      await player.setReleaseMode(ReleaseMode.release);
      player.onPlayerComplete.first.then((_) => player.dispose());
      await player.play(AssetSource('fx/${sfx.file}'), volume: 0.9);
    } catch (e) {
      GlobalExceptionHandler.log('SFX ${sfx.name} failed: $e');
    }
  }
}
