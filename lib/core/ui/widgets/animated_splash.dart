import 'package:flutter/material.dart';
import '../zyra_theme.dart';
import '../../../l10n/l10n_extension.dart';
import '../responsive.dart';
import 'glass_card.dart';

class AnimatedSplashOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const AnimatedSplashOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<AnimatedSplashOverlay> createState() => _AnimatedSplashOverlayState();
}

class _AnimatedSplashOverlayState extends State<AnimatedSplashOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 280));
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZyraColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: NocturneLampGlow(
                  radius: 0.85,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: context.scaled(88),
                          height: context.scaled(88),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ZyraColors.surface,
                            border: Border.all(
                              color: ZyraColors.primary.withValues(alpha: 0.45),
                              width: 1.2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.local_cafe_outlined,
                              color: ZyraColors.primary,
                              size: 38,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'NOCTURNE',
                          style: ZyraTypography.sectionLabel.copyWith(
                            color: ZyraColors.primary,
                            letterSpacing: 3.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Study Cafe',
                          style: ZyraTypography.editorialItalic.copyWith(
                            fontSize: 30,
                            color: ZyraColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          context.l10n.splashTagline,
                          textAlign: TextAlign.center,
                          style: ZyraTypography.bodySmall.copyWith(
                            color: ZyraColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
