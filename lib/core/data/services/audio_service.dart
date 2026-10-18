import 'package:audioplayers/audioplayers.dart';
import '../../utils/global_exception_handler.dart';

class AudioService {
  static AudioPlayer? _player;
  static bool _isPlaying = false;
  static bool _isProcessing = false;
  static String? _currentSoundFile;

  static Future<bool> isSoundAvailable(String soundFile) async {
    try {
      final testPlayer = AudioPlayer();
      await testPlayer.setSource(AssetSource('sounds/$soundFile'));
      await testPlayer.dispose();
      return true;
    } catch (e) {
      GlobalExceptionHandler.log('Sound file not available: $soundFile');
      return false;
    }
  }

  static Future<void> playAmbient(String soundFile) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final available = await isSoundAvailable(soundFile);
      if (!available) {
        GlobalExceptionHandler.log(
          'Sound asset missing: $soundFile. Skipping playback.',
        );
        return;
      }

      await _player?.stop();
      await _player?.dispose();
      _player = null;

      final newPlayer = AudioPlayer();
      await newPlayer.setSource(AssetSource('sounds/$soundFile'));
      await newPlayer.setReleaseMode(ReleaseMode.loop);
      await newPlayer.setVolume(0.7);

      _player = newPlayer;
      await _player!.resume();
      _isPlaying = true;
      _currentSoundFile = soundFile;
    } catch (e, stack) {
      await _player?.dispose();
      _player = null;
      _isPlaying = false;
      _currentSoundFile = null;
      GlobalExceptionHandler.logError(e, stack, 'playAmbient failed');
    } finally {
      _isProcessing = false;
    }
  }

  static Future<void> stopAmbient() async {
    await _player?.stop();
    await _player?.dispose();
    _player = null;
    _isPlaying = false;
    _currentSoundFile = null;
  }

  static Future<void> setVolume(double volume) async {
    await _player?.setVolume(volume.clamp(0.0, 1.0));
  }

  static bool get isPlaying => _isPlaying;
  static String? get currentSound => _currentSoundFile;

  static Future<void> dispose() async {
    await stopAmbient();
  }
}
