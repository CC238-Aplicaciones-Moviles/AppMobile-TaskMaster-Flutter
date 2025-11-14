import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/tasks/TaskDto.dart';
import '../../bloc/Tasks/TasksBloc.dart';

class TaskCard extends StatelessWidget {
  final TaskDto task;

  const TaskCard({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: _getPriorityColor(task.priority),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Prioridad',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getPriorityText(task.priority),
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Checkbox(
              value: _isChecked(task.status),
              onChanged: (value) {
                _handleCheckboxChange(context, task, value ?? false);
              },
              side: BorderSide(color: colorScheme.onSurface, width: 2),
              fillColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return colorScheme.onSurface;
                  }
                  return Colors.transparent;
                },
              ),
              checkColor: colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }

  bool _isChecked(TaskStatus status) {
    return status == TaskStatus.DONE;
  }

  void _handleCheckboxChange(BuildContext context, TaskDto task, bool isChecked) {
    String newStatus;

    if (isChecked) {
      if (task.status == TaskStatus.TO_DO) {
        newStatus = 'IN_PROGRESS';
      } else if (task.status == TaskStatus.IN_PROGRESS) {
        newStatus = 'DONE';
      } else {
        return;
      }
    } else {
      if (task.status == TaskStatus.DONE) {
        newStatus = 'TO_DO';
      } else {
        return;
      }
    }

    context.read<TasksBloc>().add(
      TaskStatusUpdateRequested(
        taskId: task.id,
        status: newStatus,
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.HIGH:
        return const Color(0xFFF1797A);
      case TaskPriority.MEDIUM:
        return const Color(0xFFFFED8C);
      case TaskPriority.LOW:
        return const Color(0xFF8CFF90);
      default:
        return Colors.blue;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.HIGH:
        return 'Alta';
      case TaskPriority.MEDIUM:
        return 'Media';
      case TaskPriority.LOW:
        return 'Baja';
      default:
        return 'N/A';
    }
  }
}
