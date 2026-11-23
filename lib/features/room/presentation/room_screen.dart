import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/services/share_service.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../social/presentation/social_providers.dart';
import '../data/room_api.dart';

/// Study together: join a friend's room with their invite code, or host your
/// own with yours, and see who studied recently.
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.roomTitle, style: ZyraTypography.headlineMedium),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: !signedIn
            ? Center(child: Text(l10n.roomSignInRequired))
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
        Text(l10n.roomIntro,
            style: ZyraTypography.bodyMedium
                .copyWith(color: ZyraColors.onSurface.withValues(alpha: 0.8))),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          maxLength: 6,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: l10n.roomCodeHint,
            errorText: _error,
          ),
          onSubmitted: _join,
        ),
        FilledButton(
          onPressed: _busy ? null : () => _join(_controller.text),
          child: Text(l10n.roomJoin),
        ),
        if (myCode != null) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : () => _join(myCode),
            child: Text(l10n.roomHost(myCode)),
          ),
        ],
      ],
    );
  }

  Widget _roomView(AppLocalizations l10n, String code) {
    final members = ref.watch(_membersProvider(code));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.roomCodeLabel(code),
                  style: ZyraTypography.titleMedium
                      .copyWith(color: ZyraColors.primary)),
            ),
            IconButton(
              icon: const Icon(Icons.share),
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
        const SizedBox(height: 8),
        Expanded(
          child: members.when(
            data: (list) => ListView(
              children: [
                for (final m in list)
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(m.name),
                    subtitle: Text(_ago(l10n, m.lastActive)),
                  ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text(l10n.roomJoinFailed)),
          ),
        ),
        TextButton(onPressed: _leave, child: Text(l10n.roomLeave)),
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

final _membersProvider = StreamProvider.autoDispose.family<List<RoomMember>, String>(
  (ref, code) => ref.watch(roomApiProvider).members(code),
);
