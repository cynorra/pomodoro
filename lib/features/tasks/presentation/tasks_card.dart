import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/task_rules.dart';

/// A small to-do list on the home screen, kept on the device.
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ZyraColors.onSurface.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist, color: ZyraColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.tasksTitle,
                style: ZyraTypography.titleMedium
                    .copyWith(color: ZyraColors.primary),
              ),
            ],
          ),
          for (final t in _tasks)
            Row(
              children: [
                Checkbox(
                  value: t.done,
                  activeColor: ZyraColors.primary,
                  onChanged: (_) => _toggle(t),
                ),
                Expanded(
                  child: Text(
                    t.title,
                    style: ZyraTypography.bodyMedium.copyWith(
                      decoration: t.done ? TextDecoration.lineThrough : null,
                      color: ZyraColors.onSurface
                          .withValues(alpha: t.done ? 0.4 : 0.9),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: l10n.tasksDelete,
                  onPressed: () => _remove(t),
                ),
              ],
            ),
          TextField(
            controller: _controller,
            maxLength: maxTaskLength,
            decoration: InputDecoration(
              hintText: l10n.tasksAddHint,
              counterText: '',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
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
