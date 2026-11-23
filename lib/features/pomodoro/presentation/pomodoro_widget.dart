import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/data/services/share_service.dart';
import '../../cafe/domain/cafe_rules.dart';
import '../../social/presentation/social_providers.dart';
import '../../subjects/presentation/subject_chip.dart';
import '../domain/pomodoro_state.dart';
import 'pomodoro_notifier.dart';
import 'package:flutter/services.dart';
import '../../../core/data/services/sfx_service.dart';
import 'reward_burst.dart';

class PomodoroWidget extends ConsumerWidget {
  const PomodoroWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
    final l10n = AppLocalizations.of(context);

    // Tell the user what the session they just finished paid out.
    ref.listen<SessionReward?>(
      pomodoroProvider.select((s) => s.lastReward),
      (previous, reward) {
        if (reward == null || reward.id == previous?.id) return;
        if (!reward.wasFocus) {
          // Break is over: a soft descending pair and a light tap.
          SfxService.play(Sfx.breakEnd);
          HapticFeedback.lightImpact();
          return;
        }
        if (reward.points <= 0) return;
        showRewardBurst(
          context,
          points: reward.points,
          boostLabel: reward.boostPercent > 0
              ? l10n.sessionRewardBoost(
                  reward.points, boostLabel(reward.boostPercent))
              : null,
        );
      },
    );

    String sessionLabel;
    switch (state.sessionType) {
      case SessionType.focus:
        sessionLabel = l10n.deepFocus;
        break;
      case SessionType.shortBreak:
        sessionLabel = l10n.cafeBreak;
        break;
      case SessionType.longBreak:
        sessionLabel = l10n.longBreak;
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
            if (state.sessionType == SessionType.focus) ...[
              const SizedBox(height: 12),
              const SubjectChip(),
            ],
            const SizedBox(height: 24),
            _TimerDisplay(remainingSeconds: state.remainingSeconds),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Semantics(
                  button: true,
                  label: state.isRunning ? l10n.pauseTimer : l10n.startTimer,
                  child: GestureDetector(
                    onTapUp: (_) => notifier.toggleTimer(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: ZyraColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: ZyraColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        state.isRunning ? l10n.pause : l10n.start,
                        style: ZyraTypography.labelLarge.copyWith(
                          color: ZyraColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: l10n.reset,
                  child: OutlinedButton(
                    onPressed: notifier.resetTimer,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ZyraColors.primary,
                      side: const BorderSide(color: ZyraColors.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.reset,
                      style: ZyraTypography.labelLarge,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _inviteToFocus(ref, l10n),
              icon: const Icon(Icons.group_add_rounded, size: 20),
              label: Text(l10n.focusTogether),
              style: TextButton.styleFrom(foregroundColor: ZyraColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  /// "Let's do a pomodoro together": shares the store link, with the user's
  /// invite code when they are signed in so the friend gets the bonus too.
  Future<void> _inviteToFocus(WidgetRef ref, AppLocalizations l10n) async {
    String? code;
    if (ref.read(signedInProvider)) {
      try {
        code = await ref.read(inviteCodeProvider.future);
      } catch (_) {
        code = null;
      }
    }
    final link = ShareService.generateInviteLink(referralCode: code);
    final text = code == null
        ? l10n.focusTogetherMessage(link)
        : l10n.focusTogetherMessageWithCode(code, link);
    await ShareService.shareGeneral(text: text);
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
