import 'package:flutter/material.dart';
import '../../models/tasks/TaskDto.dart';
import 'TaskCard.dart';

class TasksKanbanView extends StatelessWidget {
  final List<TaskDto> tasks;
  final String searchQuery;

  const TasksKanbanView({
    Key? key,
    required this.tasks,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredTasks = searchQuery.isEmpty
        ? tasks
        : tasks.where((task) =>
    task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        task.description.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    final todoTasks = filteredTasks.where((task) => task.status == TaskStatus.TO_DO).toList();
    final inProgressTasks = filteredTasks.where((task) => task.status == TaskStatus.IN_PROGRESS).toList();
    final doneTasks = filteredTasks.where((task) => task.status == TaskStatus.DONE).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColumn(context, 'Por hacer', todoTasks, todoTasks.length),
          const SizedBox(width: 16),
          _buildColumn(context, 'En proceso', inProgressTasks, inProgressTasks.length),
          const SizedBox(width: 16),
          _buildColumn(context, 'Realizado', doneTasks, doneTasks.length),
        ],
      ),
    );
  }

  Widget _buildColumn(BuildContext context, String title, List<TaskDto> tasks, int count) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: screenWidth * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  count.toString(),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: tasks.isEmpty
                ? Center(
              child: Text(
                'No hay tareas',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
