import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/task_rules.dart';

/// Nocturne Atelier to-do list card with circular 20px matcha checkboxes.
class TasksCard extends StatefulWidget {
  const TasksCard({super.key});

  @override
  State<TasksCard> createState() => _TasksCardState();
}

class _TasksCardState extends State<TasksCard> {
  static const _storage = FlutterSecureStorage();
  static const _key = 'tasks_v1';

  List<TaskItem> _tasks = [];
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final tasks = decodeTasks(await _storage.read(key: _key));
      if (mounted) setState(() => _tasks = tasks);
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      await _storage.write(key: _key, value: encodeTasks(_tasks));
    } catch (_) {}
  }

  void _add() {
    final next = addTask(_tasks, _controller.text);
    _controller.clear();
    setState(() => _tasks = next);
    _save();
  }

  void _toggle(TaskItem t) {
    setState(() {
      _tasks = sortedTasks([
        for (final x in _tasks) identical(x, t) ? x.toggled() : x,
      ]);
    });
    _save();
  }

  void _remove(TaskItem t) {
    setState(() => _tasks = _tasks.where((x) => !identical(x, t)).toList());
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.checklist_rounded,
                color: ZyraColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.tasksTitle.toUpperCase(),
                style: ZyraTypography.sectionLabel.copyWith(
                  color: ZyraColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (_tasks.isNotEmpty)
                Text(
                  '${_tasks.where((t) => t.done).length}/${_tasks.length}',
                  style: ZyraTypography.dataMono.copyWith(
                    fontSize: 11,
                    color: ZyraColors.textTertiary,
                  ),
                ),
            ],
          ),
          if (_tasks.isNotEmpty) const SizedBox(height: 10),
          for (final t in _tasks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggle(t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.done ? ZyraColors.secondary : Colors.transparent,
                        border: Border.all(
                          color: t.done
                              ? ZyraColors.secondary
                              : ZyraColors.onBackground.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: t.done
                          ? const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: ZyraColors.onSecondary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _toggle(t),
                      child: Text(
                        t.title,
                        style: ZyraTypography.bodyMedium.copyWith(
                          decoration: t.done ? TextDecoration.lineThrough : null,
                          decorationColor: ZyraColors.textTertiary,
                          color: t.done
                              ? ZyraColors.textTertiary
                              : ZyraColors.onBackground,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: ZyraColors.textTertiary,
                    ),
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n.tasksDelete,
                    onPressed: () => _remove(t),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            maxLength: maxTaskLength,
            style: ZyraTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: l10n.tasksAddHint,
              counterText: '',
              filled: true,
              fillColor: ZyraColors.surfaceElevated,
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_rounded, color: ZyraColors.primary),
                onPressed: _add,
              ),
            ),
            onSubmitted: (_) => _add(),
          ),
        ],
      ),
    );
  }
}
