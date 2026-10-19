import 'package:flutter/material.dart';
import '../../../core/data/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_extension.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.help,
          style: ZyraTypography.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FaqItem(
            question: context.l10n.faqPomodoroQ,
            answer:
                context.l10n.faqPomodoroA,
          ),
          _FaqItem(
            question: context.l10n.faqPointsQ,
            answer:
                context.l10n.faqPointsA,
          ),
          _FaqItem(
            question: context.l10n.faqCafeQ,
            answer:
                context.l10n.faqCafeA,
          ),
          _FaqItem(
            question: context.l10n.faqStreakQ,
            answer:
                context.l10n.faqStreakA,
          ),
          _FaqItem(
            question: context.l10n.faqDataQ,
            answer:
                context.l10n.faqDataA,
          ),
          _FaqItem(
            question: context.l10n.faqDeleteQ,
            answer:
                context.l10n.faqDeleteA,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ZyraColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ZyraColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.helpMoreQuestions,
                  style: ZyraTypography.titleMedium.copyWith(
                    color: ZyraColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.contactUs('eren.gp54@gmail.com'),
                  style: ZyraTypography.bodyMedium.copyWith(
                    color: ZyraColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _LinkButton(
                        label: context.l10n.privacyPolicy,
                        onTap: () =>
                            _launchUrl(AuthService.privacyPolicyUrl(context.l10n.localeName)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LinkButton(
                        label: context.l10n.termsOfService,
                        onTap: () =>
                            _launchUrl(AuthService.termsOfServiceUrl(context.l10n.localeName)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ZyraColors.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: ZyraTypography.titleMedium.copyWith(
                        color: ZyraColors.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: ZyraColors.primary,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: ZyraTypography.bodyMedium.copyWith(
                  color: ZyraColors.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _LinkButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ZyraColors.primary.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style: ZyraTypography.labelLarge.copyWith(
                color: ZyraColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
