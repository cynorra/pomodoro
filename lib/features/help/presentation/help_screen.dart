import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';

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
          l10n?.help ?? 'Yardım',
          style: ZyraTypography.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FaqItem(
            question: 'Pomodoro tekniği nedir?',
            answer:
                '25 dakika odaklanma, 5 dakika mola prensibine dayalı verimli çalışma yöntemidir. Her 4 seans sonrası 15-30 dakika uzun mola verilir.',
          ),
          _FaqItem(
            question: 'Puanlarımı nasıl kazanırım?',
            answer:
                'Her tamamlanan Pomodoro seansı için 10 puan, molalar için 2 puan kazanırsın. Reklam izleyerek de +50 puan kazanabilirsin.',
          ),
          _FaqItem(
            question: 'Sanal kafede ne yapabilirim?',
            answer:
                'Kazandığın puanlarla kahve, çay, tatlı gibi sanal ürünler alabilir, ortam sesleri ile çalışma atmosferini özelleştirebilirsin.',
          ),
          _FaqItem(
            question: 'Streak (seri) nasıl korunur?',
            answer:
                'Her gün en az bir Pomodoro seansı tamamlarsan serin devam eder. Bir gün atlarsan seri sıfırlanır.',
          ),
          _FaqItem(
            question: 'Verilerim güvende mi?',
            answer:
                'Tüm verilerin cihazında şifrelenmiş olarak saklanır. Cloud sync için giriş yapman gerekir. Gizlilik politikamızı okuyabilirsin.',
          ),
          _FaqItem(
            question: 'Premium ne sağlar?',
            answer:
                'Reklamsız deneyim, 50+ premium ortam sesi, özel temalar, global leaderboard ve öncelikli destek.',
          ),
          _FaqItem(
            question: 'Hesabımı nasıl silerim?',
            answer:
                'Profil → Hesabı Sil menüsünden veya cynora.com/delete-account adresinden hesabını kalıcı olarak silebilirsin.',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ZyraColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ZyraColors.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Başka sorunun mu var?',
                  style: ZyraTypography.titleMedium.copyWith(
                    color: ZyraColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bize ulaş: support@cynora.com',
                  style: ZyraTypography.bodyMedium.copyWith(
                    color: ZyraColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _LinkButton(
                        label: 'Gizlilik Politikası',
                        onTap: () =>
                            _launchUrl('https://cynora.com/privacy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LinkButton(
                        label: 'Kullanım Şartları',
                        onTap: () =>
                            _launchUrl('https://cynora.com/terms'),
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
        color: ZyraColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ZyraColors.onSurface.withOpacity(0.1),
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
                  color: ZyraColors.onSurface.withOpacity(0.7),
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
      color: ZyraColors.primary.withOpacity(0.15),
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
