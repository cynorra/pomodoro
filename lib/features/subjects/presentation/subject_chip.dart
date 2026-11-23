import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/subject_rules.dart';
import 'subject_notifier.dart';

/// Small chip above the timer: pick what you are studying (or add a subject).
class SubjectChip extends ConsumerWidget {
  const SubjectChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(subjectProvider);
    return ActionChip(
      avatar: const Icon(Icons.menu_book_outlined,
          size: 18, color: ZyraColors.primary),
      label: Text(s.selected.isEmpty ? l10n.subjectPick : s.selected),
      onPressed: () => _open(context),
    );
  }

  Future<void> _open(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ZyraColors.surface,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final s = ref.watch(subjectProvider);
          return Padding(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.subjectTitle,
                      style: ZyraTypography.titleMedium
                          .copyWith(color: ZyraColors.primary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.subjectNone),
                        selected: s.selected.isEmpty,
                        onSelected: (_) {
                          ref.read(subjectProvider.notifier).select('');
                          Navigator.pop(ctx);
                        },
                      ),
                      for (final name in s.subjects)
                        InputChip(
                          label: Text(name),
                          selected: s.selected == name,
                          onPressed: () {
                            ref.read(subjectProvider.notifier).select(name);
                            Navigator.pop(ctx);
                          },
                          onDeleted: () =>
                              ref.read(subjectProvider.notifier).remove(name),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLength: maxSubjectLength,
                    decoration: InputDecoration(
                      hintText: l10n.subjectAddHint,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          ref
                              .read(subjectProvider.notifier)
                              .add(controller.text);
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                    onSubmitted: (v) {
                      ref.read(subjectProvider.notifier).add(v);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    controller.dispose();
  }
}
