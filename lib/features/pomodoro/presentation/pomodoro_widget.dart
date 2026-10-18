import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/pomodoro_state.dart';
import 'pomodoro_notifier.dart';

class PomodoroWidget extends ConsumerWidget {
  const PomodoroWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
    final l10n = AppLocalizations.of(context);

    String sessionLabel;
    switch (state.sessionType) {
      case SessionType.focus:
        sessionLabel = l10n?.deepFocus ?? 'Derin Odak';
        break;
      case SessionType.shortBreak:
        sessionLabel = l10n?.cafeBreak ?? 'Kafe Molası';
        break;
      case SessionType.longBreak:
        sessionLabel = l10n?.longBreak ?? 'Uzun Mola';
        break;
    }

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Text(
              sessionLabel,
              style: ZyraTypography.headlineMedium.copyWith(
                color: ZyraColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            _TimerDisplay(remainingSeconds: state.remainingSeconds),
            const SizedBox(height: 32),
            Semantics(
              button: true,
              label: state.isRunning
                  ? (l10n?.pauseTimer ?? 'Zamanlayıcıyı duraklat')
                  : (l10n?.startTimer ?? 'Zamanlayıcıyı başlat'),
              child: GestureDetector(
                onTapUp: (_) => notifier.toggleTimer(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: ZyraColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: ZyraColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    state.isRunning
                        ? (l10n?.pause ?? 'Duraklat')
                        : (l10n?.start ?? 'Başlat'),
                    style: ZyraTypography.labelLarge.copyWith(
                      color: ZyraColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  final int remainingSeconds;

  const _TimerDisplay({required this.remainingSeconds});

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '$minutes:$seconds',
      style: ZyraTypography.displayLarge.copyWith(
        color: ZyraColors.onBackground,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
