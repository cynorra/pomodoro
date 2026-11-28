import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../core/ui/widgets/jelly_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/data/services/share_service.dart';
import '../../../core/data/services/sfx_service.dart';
import '../../cafe/domain/cafe_rules.dart';
import '../../cafe/presentation/boost_notifier.dart';
import '../../social/presentation/social_providers.dart';
import '../../subjects/presentation/subject_chip.dart';
import '../domain/pomodoro_state.dart';
import 'pomodoro_notifier.dart';
import 'reward_burst.dart';

class PomodoroWidget extends ConsumerWidget {
  const PomodoroWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
    final activeBoost = ref.watch(activeBoostProvider);
    final l10n = AppLocalizations.of(context);

    ref.listen<SessionReward?>(
      pomodoroProvider.select((s) => s.lastReward),
      (previous, reward) {
        if (reward == null || reward.id == previous?.id) return;
        if (!reward.wasFocus) {
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

    final isBreak = state.sessionType != SessionType.focus;
    final accentColor = isBreak ? ZyraColors.secondary : ZyraColors.primary;
    final totalSeconds = notifier.totalSecondsFor(state.sessionType);
    final progress = totalSeconds > 0
        ? (1.0 - (state.remainingSeconds / totalSeconds)).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        // Mode segmented pill selector (Odak / Kısa Mola / Uzun Mola)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: ZyraColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ZyraColors.hairline),
          ),
          child: Row(
            children: [
              _ModeTab(
                label: l10n.deepFocus,
                selected: state.sessionType == SessionType.focus,
                accent: ZyraColors.primary,
                onTap: () => notifier.selectSessionType(SessionType.focus),
              ),
              _ModeTab(
                label: l10n.cafeBreak,
                selected: state.sessionType == SessionType.shortBreak,
                accent: ZyraColors.secondary,
                onTap: () => notifier.selectSessionType(SessionType.shortBreak),
              ),
              _ModeTab(
                label: l10n.longBreak,
                selected: state.sessionType == SessionType.longBreak,
                accent: ZyraColors.secondary,
                onTap: () => notifier.selectSessionType(SessionType.longBreak),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 60-tick Nocturne Atelier radial clock dial with static tungsten glow
        NocturneLampGlow(
          radius: 0.72,
          glowColor: accentColor.withValues(alpha: 0.11),
          child: SizedBox(
            width: 268,
            height: 268,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(268, 268),
                  painter: _RadialTickDialPainter(
                    progress: progress,
                    accentColor: accentColor,
                    isRunning: state.isRunning,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TimerDisplay(remainingSeconds: state.remainingSeconds),
                    if (state.sessionType == SessionType.focus) ...[
                      const SizedBox(height: 12),
                      const SubjectChip(),
                    ] else ...[
                      const SizedBox(height: 10),
                      const NocturnePillBadge(
                        label: 'MATCHA · MOLA',
                        dotColor: ZyraColors.secondary,
                        textColor: ZyraColors.secondaryBright,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Primary Start/Pause + Ghost Reset buttons
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Semantics(
                button: true,
                label: state.isRunning ? l10n.pauseTimer : l10n.startTimer,
                child: JellyButton(
                  onPressed: notifier.toggleTimer,
                  label: state.isRunning ? l10n.pause : l10n.start,
                  backgroundColor: accentColor,
                  textColor: ZyraColors.onPrimary,
                  icon: Icon(
                    state.isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 20,
                    color: ZyraColors.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Semantics(
                button: true,
                label: l10n.reset,
                child: JellyButton(
                  onPressed: notifier.resetTimer,
                  label: l10n.reset,
                  outlined: true,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: ZyraColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Active Cafe Brew Boost indicator (if user bought a boost in Cafe)
        if (activeBoost != null) ...[
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: ZyraColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ZyraColors.hairline),
                  ),
                  child: const Icon(
                    Icons.local_cafe_outlined,
                    color: ZyraColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeBoost.itemId.toUpperCase(),
                        style: ZyraTypography.titleMedium.copyWith(fontSize: 13),
                      ),
                      Text(
                        '${activeBoost.sessionsLeft}×',
                        style: ZyraTypography.bodySmall.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '+%${activeBoost.percent} ⚡',
                  style: ZyraTypography.dataMono.copyWith(
                    color: ZyraColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _inviteToFocus(ref, l10n),
          icon: const Icon(Icons.group_add_outlined, size: 17),
          label: Text(
            l10n.focusTogether,
            style: ZyraTypography.bodySmall.copyWith(
              color: ZyraColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

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

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ZyraTypography.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? ZyraColors.onPrimary : ZyraColors.textSecondary,
            ),
          ),
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
        fontSize: 54,
        color: ZyraColors.onBackground,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// Draws 60 radial clock ticks around the timer, matching `odak_zamanlay_c`.
class _RadialTickDialPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final bool isRunning;

  const _RadialTickDialPainter({
    required this.progress,
    required this.accentColor,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const tickCount = 60;
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2 - 4;
    final elapsedTicks = (progress * tickCount).round();

    for (int i = 0; i < tickCount; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / tickCount);
      final isMajor = i % 5 == 0;
      final isTop = i == 0;
      final isElapsed = i < elapsedTicks;
      final isCurrentHead = i == elapsedTicks && isRunning;

      final tickLength = isTop
          ? 14.0
          : (isMajor ? 11.0 : 7.0);
      final innerR = outerR - tickLength;

      Color color;
      if (isTop || isCurrentHead) {
        color = accentColor;
      } else if (isElapsed) {
        color = ZyraColors.textTertiary.withValues(alpha: 0.35);
      } else {
        color = isMajor
            ? ZyraColors.onBackground.withValues(alpha: 0.85)
            : ZyraColors.onBackground.withValues(alpha: 0.45);
      }

      final paint = Paint()
        ..color = color
        ..strokeWidth = isTop || isCurrentHead ? 2.2 : (isMajor ? 1.6 : 1.1)
        ..strokeCap = StrokeCap.round;

      final p1 = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadialTickDialPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.isRunning != isRunning;
}
