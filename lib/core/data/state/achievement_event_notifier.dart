import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';

class AchievementEventStream {
  static final _controller = StreamController<Achievement>.broadcast();

  static Stream<Achievement> get stream => _controller.stream;

  static void emit(Achievement achievement) {
    if (!_controller.isClosed) {
      _controller.add(achievement);
    }
  }

  static void dispose() {
    _controller.close();
  }
}

final achievementEventProvider = StreamProvider<Achievement>((ref) {
  return AchievementEventStream.stream;
});
