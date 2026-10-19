import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/jelly_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_extension.dart';
import '../../home/presentation/main_shell.dart';
import '../../../core/ui/responsive.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  final _storage = const FlutterSecureStorage();

  List<_OnboardingPage> _pages(BuildContext context) => [
    _OnboardingPage(
      icon: Icons.timer_rounded,
      title: context.l10n.onboardFocusTitle,
      description: context.l10n.onboardFocusBody,
      color: ZyraColors.primary,
    ),
    _OnboardingPage(
      icon: Icons.coffee_rounded,
      title: context.l10n.onboardEarnTitle,
      description: context.l10n.onboardEarnBody,
      color: ZyraColors.secondary,
    ),
    _OnboardingPage(
      icon: Icons.emoji_events_rounded,
      title: context.l10n.onboardAchieveTitle,
      description: context.l10n.onboardAchieveBody,
      color: Colors.orange,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await _storage.write(key: 'onboarding_completed', value: 'true');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ZyraColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  context.l10n.onboardSkip,
                  style: ZyraTypography.labelLarge.copyWith(
                    color: ZyraColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages(context).length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages(context)[index];
                  final compact = context.isShort;
                  return LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: EdgeInsets.all(compact ? 16 : 32),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - (compact ? 32 : 64),
                        ),
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: context.scaled(compact ? 100 : 160),
                          height: context.scaled(compact ? 100 : 160),
                          decoration: BoxDecoration(
                            color: page.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: page.color.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            page.icon,
                            color: page.color,
                            size: context.scaled(compact ? 50 : 80),
                          ),
                        ),
                        SizedBox(height: compact ? 20 : 48),
                        Text(
                          page.title,
                          style: ZyraTypography.headlineLarge.copyWith(
                            color: page.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: ZyraTypography.bodyMedium.copyWith(
                            color: ZyraColors.onSurface.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
                _pages(context).length,
                (index) => Container(
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? ZyraColors.primary
                        : ZyraColors.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: JellyButton(
                onPressed: () {
                  if (_currentPage == _pages(context).length - 1) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
                label: _currentPage == _pages(context).length - 1
                    ? (l10n.start)
                    : context.l10n.onboardNext,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
