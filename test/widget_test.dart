import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/core/data/state/user_notifier.dart';
import 'package:cynora_focus/core/data/state/user_state.dart';

void main() {
  ProviderContainer makeContainer(int points) => ProviderContainer(
        overrides: [
          initialUserProvider.overrideWithValue(UserState(totalPoints: points)),
        ],
      );

  test('addPoints increases the balance', () async {
    final container = makeContainer(10);
    addTearDown(container.dispose);

    await container.read(userProvider.notifier).addPoints(25);

    expect(container.read(userProvider).totalPoints, 35);
  });

  test('deductPoints never goes below zero', () async {
    final container = makeContainer(20);
    addTearDown(container.dispose);

    await container.read(userProvider.notifier).deductPoints(50);

    expect(container.read(userProvider).totalPoints, 0);
  });

  test('addStudyMinutes accumulates', () async {
    final container = makeContainer(0);
    addTearDown(container.dispose);

    final notifier = container.read(userProvider.notifier);
    await notifier.addStudyMinutes(25);
    await notifier.addStudyMinutes(5);

    expect(container.read(userProvider).totalStudyMinutes, 30);
  });
}
