import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/zyra_theme.dart';
import '../../../../core/data/services/share_service.dart';
import '../../../../core/data/services/share_card_generator.dart';
import '../../../../core/data/services/share_card_capture.dart';
import '../../../../core/data/state/user_notifier.dart';
import '../../../../core/data/state/streak_notifier.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ShareButton extends ConsumerStatefulWidget {
  final int minutesStudied;
  final int pointsEarned;
  final String sessionType;

  const ShareButton({
    super.key,
    required this.minutesStudied,
    required this.pointsEarned,
    required this.sessionType,
  });

  @override
  ConsumerState<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends ConsumerState<ShareButton> {
  final _cardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share_outlined, color: ZyraColors.primary),
      onPressed: () => _showShareSheet(context),
    );
  }

  void _showShareSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userState = ref.read(userProvider);
    final streak = ref.read(streakProvider).value ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: ZyraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Başarını Paylaş',
                style: ZyraTypography.headlineMedium.copyWith(
                  color: ZyraColors.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              RepaintBoundary(
                key: _cardKey,
                child: ShareCardGenerator.buildSessionCompleteCard(
                  minutesStudied: widget.minutesStudied,
                  pointsEarned: widget.pointsEarned,
                  currentStreak: streak,
                  sessionType: widget.sessionType,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShareOption(
                    icon: Icons.chat,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () async {
                      Navigator.pop(context);
                      await _shareToWhatsApp(userState.totalPoints, streak);
                    },
                  ),
                  _ShareOption(
                    icon: Icons.camera_alt,
                    label: 'Instagram',
                    color: const Color(0xFFE4405F),
                    onTap: () async {
                      Navigator.pop(context);
                      await _shareToInstagram();
                    },
                  ),
                  _ShareOption(
                    icon: Icons.music_note,
                    label: 'TikTok',
                    color: Colors.black,
                    onTap: () async {
                      Navigator.pop(context);
                      await _shareToTikTok();
                    },
                  ),
                  _ShareOption(
                    icon: Icons.share,
                    label: 'Diğer',
                    color: ZyraColors.primary,
                    onTap: () async {
                      Navigator.pop(context);
                      await _shareGeneral(userState.totalPoints, streak);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n?.close ?? 'Kapat',
                  style: ZyraTypography.labelLarge.copyWith(
                    color: ZyraColors.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildShareText(int totalPoints, int streak) {
    return '''
🎯 Bugün ${widget.minutesStudied} dakika odaklandım!

🔥 $streak günlük serim devam ediyor
⭐ Toplam $totalPoints puan kazandım

Sen de Study Cafe ile odaklanmaya başla!
${ShareService.getAppStoreLink()}

#StudyCafe #Pomodoro #StudyGram #Odaklan
''';
  }

  Future<void> _shareToWhatsApp(int totalPoints, int streak) async {
    final text = _buildShareText(totalPoints, streak);
    final file = await ShareCardCapture.capture(_cardKey);
    await ShareService.shareToWhatsApp(text: text, image: file);
    _rewardViralShare();
  }

  void _rewardViralShare() {
    ref.read(userProvider.notifier).addPoints(25);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Paylaştığın için +25 Puan kazandın!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _shareToInstagram() async {
    final file = await ShareCardCapture.capture(_cardKey);
    if (file == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kart oluşturulamadı')),
        );
      }
      return;
    }
    await ShareService.shareToInstagramStories(imageFile: file);
    _rewardViralShare();
  }

  Future<void> _shareToTikTok() async {
    final file = await ShareCardCapture.capture(_cardKey);
    if (file == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kart oluşturulamadı')),
        );
      }
      return;
    }
    await ShareService.shareToTikTok(videoOrImage: file);
    _rewardViralShare();
  }

  Future<void> _shareGeneral(int totalPoints, int streak) async {
    final text = _buildShareText(totalPoints, streak);
    final file = await ShareCardCapture.capture(_cardKey);
    if (file != null) {
      await ShareService.shareGeneral(text: text, images: [file]);
    } else {
      await ShareService.shareGeneral(text: text);
    }
    _rewardViralShare();
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: ZyraTypography.labelSmall.copyWith(
              color: ZyraColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
