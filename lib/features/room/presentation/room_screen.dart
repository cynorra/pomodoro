import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/services/share_service.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../core/ui/widgets/jelly_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../social/presentation/social_providers.dart';
import '../data/room_api.dart';

/// Nocturne Atelier "Gece Kütüphanesi" study room screen.
class RoomScreen extends ConsumerStatefulWidget {
  const RoomScreen({super.key});

  @override
  ConsumerState<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends ConsumerState<RoomScreen> {
  final _controller = TextEditingController();
  String? _code;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.read(roomApiProvider).joinedCode().then((c) {
      if (mounted) setState(() => _code = c);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join(String raw) async {
    final l10n = AppLocalizations.of(context);
    final code = raw.trim().toUpperCase();
    if (code.length != 6) {
      setState(() => _error = l10n.roomCodeInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await ref.read(roomApiProvider).join(code);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) {
        _code = code;
      } else {
        _error = l10n.roomJoinFailed;
      }
    });
  }

  Future<void> _leave() async {
    await ref.read(roomApiProvider).leave();
    if (mounted) setState(() => _code = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final signedIn = ref.watch(signedInProvider);

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: ZyraColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.roomTitle, style: ZyraTypography.titleLarge),
            Text(
              'GECE KÜTÜPHANESİ',
              style: ZyraTypography.sectionLabel.copyWith(
                fontSize: 10,
                color: ZyraColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: !signedIn
            ? Center(
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.roomSignInRequired,
                    style: ZyraTypography.bodyMedium.copyWith(
                      color: ZyraColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : _code == null
                ? _joinForm(l10n)
                : _roomView(l10n, _code!),
      ),
    );
  }

  Widget _joinForm(AppLocalizations l10n) {
    final myCode = ref.watch(inviteCodeProvider).value;
    return ListView(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NocturnePillBadge(
                label: 'KÜTÜPHANE & ŞÖMİNE · 38 dB',
                dotColor: ZyraColors.primary,
              ),
              const SizedBox(height: 14),
              Text(
                '“Fısıltı dahi yok; yalnızca sayfaların hışırtısı ve lamba ışığı.”',
                style: ZyraTypography.editorialItalic.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.roomIntro,
                style: ZyraTypography.bodySmall.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                maxLength: 6,
                textCapitalization: TextCapitalization.characters,
                style: ZyraTypography.dataMono.copyWith(
                  fontSize: 18,
                  letterSpacing: 3,
                ),
                decoration: InputDecoration(
                  hintText: l10n.roomCodeHint,
                  errorText: _error,
                  counterText: '',
                ),
                onSubmitted: _join,
              ),
              const SizedBox(height: 14),
              JellyButton(
                onPressed: _busy ? null : () => _join(_controller.text),
                label: l10n.roomJoin,
              ),
              if (myCode != null) ...[
                const SizedBox(height: 10),
                JellyButton(
                  onPressed: _busy ? null : () => _join(myCode),
                  label: l10n.roomHost(myCode),
                  outlined: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _roomView(AppLocalizations l10n, String code) {
    final members = ref.watch(_membersProvider(code));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department_outlined,
                color: ZyraColors.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.roomCodeLabel(code),
                      style: ZyraTypography.dataMono.copyWith(
                        color: ZyraColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Kütüphane & Şömine Çıtırtısı · 38 dB',
                      style: ZyraTypography.bodySmall.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.share_outlined,
                  color: ZyraColors.onBackground,
                  size: 20,
                ),
                onPressed: () => ShareService.shareGeneral(
                  text: l10n.roomInviteMessage(
                    code,
                    ShareService.generateInviteLink(
                      referralCode: code,
                      campaign: 'study_room',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: members.when(
            data: (list) => GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final m = list[index];
                final activeNow = m.lastActive != null &&
                    DateTime.now().difference(m.lastActive!).inMinutes < 5;
                final initials = m.name.trim().isNotEmpty
                    ? m.name.trim().characters.take(2).toString().toUpperCase()
                    : 'M';
                return GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: activeNow
                                  ? ZyraColors.primary.withValues(alpha: 0.2)
                                  : ZyraColors.surfaceElevated,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: activeNow
                                    ? ZyraColors.primary
                                    : ZyraColors.hairlineStrong,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: ZyraTypography.dataMono.copyWith(
                                fontSize: 12,
                                color: activeNow
                                    ? ZyraColors.primaryBright
                                    : ZyraColors.onBackground,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Masa ${index + 1}',
                            style: ZyraTypography.dataMono.copyWith(
                              fontSize: 11,
                              color: ZyraColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        m.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ZyraTypography.titleMedium.copyWith(fontSize: 14),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: activeNow
                              ? ZyraColors.primary.withValues(alpha: 0.12)
                              : ZyraColors.secondaryContainer
                                  .withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: activeNow
                                    ? ZyraColors.primary
                                    : ZyraColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _ago(l10n, m.lastActive),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ZyraTypography.dataMono.copyWith(
                                  fontSize: 11,
                                  color: activeNow
                                      ? ZyraColors.primaryBright
                                      : ZyraColors.secondaryBright,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: ZyraColors.primary),
            ),
            error: (_, __) => Center(child: Text(l10n.roomJoinFailed)),
          ),
        ),
        const SizedBox(height: 10),
        JellyButton(
          onPressed: _leave,
          label: l10n.roomLeave,
          outlined: true,
        ),
      ],
    );
  }

  String _ago(AppLocalizations l10n, DateTime? t) {
    if (t == null) return '';
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 5) return l10n.roomActiveNow;
    if (d.inHours < 1) return l10n.roomActiveMinutes(d.inMinutes);
    if (d.inHours < 24) return l10n.roomActiveHours(d.inHours);
    return l10n.roomActiveDays(d.inDays);
  }
}

final _membersProvider =
    StreamProvider.autoDispose.family<List<RoomMember>, String>(
  (ref, code) => ref.watch(roomApiProvider).members(code),
);
