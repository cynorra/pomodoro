import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/pomodoro/presentation/reward_burst.dart';

void main() {
  testWidgets('reward burst shows the points and then removes itself',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showRewardBurst(
                  context,
                  points: 25,
                  boostLabel: '+50%',
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('+25'), findsOneWidget);
    expect(find.text('+50%'), findsOneWidget);

    // Runs its full 2.2 s animation (and the delayed coin ping), then is gone.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('+25'), findsNothing);
  });
}
