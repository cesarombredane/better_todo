import 'package:better_todo/data/models/todo_models.dart';
import 'package:better_todo/theme/app_colors.dart';
import 'package:flutter/material.dart';

final class SubtaskSummary extends StatelessWidget {
  const SubtaskSummary({
    required this.subtasks,
    required this.onToggle,
    super.key,
  });

  final List<TodoSubtaskModel> subtasks;
  final ValueChanged<TodoSubtaskModel> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final subtask in subtasks)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: subtask.isCompleted,
                      shape: const CircleBorder(),
                      onChanged: (_) => onToggle(subtask),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    subtask.content,
                    style: TextStyle(
                      color: subtask.isCompleted
                          ? AppColors.textDisabled
                          : AppColors.textSecondary,
                      decoration: subtask.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
