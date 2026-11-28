import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../core/ui/widgets/jelly_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_extension.dart';
import '../../home/domain/daily_goal.dart';
import '../../../core/ui/responsive.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  /// Called once the user finishes (or skips); the parent decides what comes next
  /// (consent screen, then the app).
  final VoidCallback onDone;

  const OnboardingScreen({super.key, required this.onDone});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  final _storage = const FlutterSecureStorage();
  int _goalMinutes = defaultDailyGoalMinutes;

  List<_OnboardingPage> _pages(BuildContext context) => [
        _OnboardingPage(
          tag: 'FASIL · I / III',
          title: context.l10n.onboardFocusTitle,
          description: context.l10n.onboardFocusBody,
          artwork: _OnboardingArtwork.cup,
          accent: ZyraColors.primary,
          brewNote: ('Etiyopya Yirgacheffe', 'Karanfil · Narenciye · 92°C', 'DEMLEME #04'),
        ),
        _OnboardingPage(
          tag: 'HUZUR · II / III',
          title: context.l10n.onboardEarnTitle,
          description: context.l10n.onboardEarnBody,
          artwork: _OnboardingArtwork.window,
          accent: ZyraColors.secondary,
        ),
        _OnboardingPage(
          tag: 'ATÖLYE · III / III',
          title: context.l10n.onboardAchieveTitle,
          description: context.l10n.onboardAchieveBody,
          artwork: _OnboardingArtwork.table,
          accent: ZyraColors.primary,
        ),
      ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await _storage.write(key: 'daily_goal_minutes', value: '$_goalMinutes');
    await _storage.write(key: 'onboarding_completed', value: 'true');
    if (!mounted) return;
    widget.onDone();
  }

  Widget _goalPage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NocturneLampGlow(
            child: SizedBox(
              width: 170,
              height: 170,
              child: CustomPaint(
                painter: _NocturneArtworkPainter(_OnboardingArtwork.table),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const NocturnePillBadge(
            label: 'RİTİM · GÜNLÜK HEDEF',
            dotColor: ZyraColors.primary,
          ),
          const SizedBox(height: 18),
          Text(
            context.l10n.onboardGoalTitle,
            style: ZyraTypography.editorialItalic.copyWith(fontSize: 28),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.onboardGoalBody,
            style: ZyraTypography.bodyMedium.copyWith(
              color: ZyraColors.textSecondary,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final m in dailyGoalOptions)
                  GestureDetector(
                    onTap: () => setState(() => _goalMinutes = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _goalMinutes == m
                            ? ZyraColors.primary
                            : ZyraColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _goalMinutes == m
                              ? ZyraColors.primary
                              : ZyraColors.hairlineStrong,
                        ),
                      ),
                      child: Text(
                        context.l10n.onboardGoalMinutes(m),
                        style: ZyraTypography.dataMono.copyWith(
                          color: _goalMinutes == m
                              ? ZyraColors.onPrimary
                              : ZyraColors.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _pages(context);
    final totalPages = pages.length + 1;
    final stepLabel = (_currentPage + 1).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: ZyraColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: NocturnePillBadge(
                      label: 'NOCTURNE ATELIER · $stepLabel',
                      dotColor: ZyraColors.primary,
                      backgroundColor: ZyraColors.surface,
                      textColor: ZyraColors.onBackground,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      context.l10n.onboardSkip,
                      style: ZyraTypography.labelLarge.copyWith(
                        color: ZyraColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: totalPages,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  if (index == pages.length) return _goalPage(context);
                  final page = pages[index];
                  final compact = context.isShort;
                  return LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: compact ? 8 : 20,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              math.max(0, constraints.maxHeight - (compact ? 16 : 40)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NocturneLampGlow(
                              radius: 0.78,
                              child: SizedBox(
                                width: context.scaled(compact ? 150 : 210),
                                height: context.scaled(compact ? 150 : 210),
                                child: CustomPaint(
                                  painter: _NocturneArtworkPainter(page.artwork),
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 12 : 24),
                            NocturnePillBadge(
                              label: page.tag,
                              textColor: page.accent,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              page.title,
                              style: ZyraTypography.editorialItalic.copyWith(
                                fontSize: compact ? 24 : 28,
                                color: ZyraColors.onBackground,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              page.description,
                              style: ZyraTypography.bodyMedium.copyWith(
                                color: ZyraColors.textSecondary,
                                height: 1.55,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (page.brewNote != null) ...[
                              const SizedBox(height: 24),
                              GlassCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: const BoxDecoration(
                                        color: ZyraColors.secondaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.local_cafe_outlined,
                                        color: ZyraColors.secondaryBright,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            page.brewNote!.$1,
                                            style: ZyraTypography.titleMedium
                                                .copyWith(fontSize: 14),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            page.brewNote!.$2,
                                            style: ZyraTypography.dataMono
                                                .copyWith(
                                              fontSize: 11,
                                              color: ZyraColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      page.brewNote!.$3,
                                      style: ZyraTypography.dataMono.copyWith(
                                        fontSize: 11,
                                        color: ZyraColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalPages,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: _currentPage == index ? 24 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? ZyraColors.primary
                        : ZyraColors.textTertiary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: JellyButton(
                onPressed: () {
                  if (_currentPage == pages.length) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
                label: _currentPage == pages.length
                    ? l10n.start
                    : context.l10n.onboardNext,
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: ZyraColors.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

enum _OnboardingArtwork { cup, window, table }

class _OnboardingPage {
  final String tag;
  final String title;
  final String description;
  final _OnboardingArtwork artwork;
  final Color accent;
  final (String, String, String)? brewNote;

  const _OnboardingPage({
    required this.tag,
    required this.title,
    required this.description,
    required this.artwork,
    required this.accent,
    this.brewNote,
  });
}

/// Minimal copper line-art illustrations matching Nocturne Atelier onboarding.
class _NocturneArtworkPainter extends CustomPainter {
  final _OnboardingArtwork kind;

  _NocturneArtworkPainter(this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    final copper = Paint()
      ..color = ZyraColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final muted = Paint()
      ..color = ZyraColors.onBackground.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    switch (kind) {
      case _OnboardingArtwork.cup:
        // Steaming coffee cup & saucer
        final cupRect = Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.62),
          width: w * 0.48,
          height: h * 0.34,
        );
        final cupPath = Path()
          ..moveTo(cupRect.left, cupRect.top)
          ..lineTo(cupRect.right, cupRect.top)
          ..quadraticBezierTo(
            cupRect.right,
            cupRect.bottom,
            w * 0.5,
            cupRect.bottom,
          )
          ..quadraticBezierTo(
            cupRect.left,
            cupRect.bottom,
            cupRect.left,
            cupRect.top,
          );
        canvas.drawPath(cupPath, copper);
        // Handle
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(cupRect.right + w * 0.03, h * 0.60),
            width: w * 0.14,
            height: h * 0.16,
          ),
          -math.pi / 2,
          math.pi,
          false,
          copper,
        );
        // Saucer
        final saucer = Path()
          ..moveTo(w * 0.2, h * 0.82)
          ..quadraticBezierTo(w * 0.5, h * 0.88, w * 0.8, h * 0.82);
        canvas.drawPath(saucer, copper);
        // Steam wisps
        for (final dx in [-0.07, 0.04]) {
          final steam = Path()
            ..moveTo(w * (0.5 + dx), h * 0.42)
            ..cubicTo(
              w * (0.46 + dx),
              h * 0.30,
              w * (0.56 + dx),
              h * 0.22,
              w * (0.49 + dx),
              h * 0.12,
            );
          canvas.drawPath(steam, muted);
        }
        break;

      case _OnboardingArtwork.window:
        // Arched night window with crescent moon & stars
        final arch = Path()
          ..moveTo(w * 0.2, h * 0.82)
          ..lineTo(w * 0.2, h * 0.30)
          ..quadraticBezierTo(w * 0.5, h * 0.12, w * 0.8, h * 0.30)
          ..lineTo(w * 0.8, h * 0.82)
          ..close();
        canvas.drawPath(arch, copper);
        canvas.drawLine(Offset(w * 0.5, h * 0.21), Offset(w * 0.5, h * 0.82), muted);
        canvas.drawLine(Offset(w * 0.2, h * 0.52), Offset(w * 0.8, h * 0.52), muted);
        // Sill
        canvas.drawLine(Offset(w * 0.14, h * 0.82), Offset(w * 0.86, h * 0.82), copper);
        // Crescent moon
        final moonPaint = Paint()
          ..color = ZyraColors.primaryBright
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6;
        canvas.drawArc(
          Rect.fromCircle(center: Offset(w * 0.64, h * 0.34), radius: w * 0.06),
          0.6,
          math.pi * 1.25,
          false,
          moonPaint,
        );
        // Stars
        final starPaint = Paint()..color = ZyraColors.onBackground.withValues(alpha: 0.7);
        for (final pt in [
          Offset(w * 0.35, h * 0.34),
          Offset(w * 0.42, h * 0.44),
          Offset(w * 0.70, h * 0.43),
        ]) {
          canvas.drawCircle(pt, 1.8, starPaint);
        }
        break;

      case _OnboardingArtwork.table:
        // Hanging pendant lamp + bistro table + two chairs
        canvas.drawLine(Offset(w * 0.5, h * 0.08), Offset(w * 0.5, h * 0.24), muted);
        final shade = Path()
          ..moveTo(w * 0.38, h * 0.34)
          ..lineTo(w * 0.44, h * 0.24)
          ..lineTo(w * 0.56, h * 0.24)
          ..lineTo(w * 0.62, h * 0.34)
          ..close();
        canvas.drawPath(shade, copper);
        // Soft light cone
        final cone = Paint()
          ..color = ZyraColors.primary.withValues(alpha: 0.07)
          ..style = PaintingStyle.fill;
        final conePath = Path()
          ..moveTo(w * 0.38, h * 0.34)
          ..lineTo(w * 0.62, h * 0.34)
          ..lineTo(w * 0.78, h * 0.74)
          ..lineTo(w * 0.22, h * 0.74)
          ..close();
        canvas.drawPath(conePath, cone);
        // Table top & stem
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.62),
            width: w * 0.44,
            height: h * 0.12,
          ),
          copper,
        );
        canvas.drawLine(Offset(w * 0.5, h * 0.68), Offset(w * 0.5, h * 0.86), copper);
        canvas.drawLine(Offset(w * 0.40, h * 0.86), Offset(w * 0.60, h * 0.86), copper);
        // Chair silhouettes
        canvas.drawLine(Offset(w * 0.22, h * 0.56), Offset(w * 0.22, h * 0.86), muted);
        canvas.drawLine(Offset(w * 0.78, h * 0.56), Offset(w * 0.78, h * 0.86), muted);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _NocturneArtworkPainter oldDelegate) =>
      oldDelegate.kind != kind;
}
