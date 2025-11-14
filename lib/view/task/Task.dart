import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/Projects/ProjectsBloc.dart';
import '../../bloc/Tasks/TasksBloc.dart';
import 'ProjectList.dart';

class Task extends StatefulWidget {
  const Task({super.key});

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> {
  String query = "";

  @override
  void initState() {
    super.initState();
    context.read<ProjectsBloc>().add(ProjectsFetchByMemberRequested());
    context.read<TasksBloc>().add(TasksFetchAllRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 70),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Text(
            "Tareas",
            style: textTheme.displayMedium?.copyWith(
              color: colorScheme.onBackground,
            ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => query = value),
                  decoration: InputDecoration(
                    hintText: "Buscar proyectos con tareas asignadas",
                    hintStyle: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: colorScheme.secondaryContainer,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/img/ic_search.png',
                        width: 20,
                        height: 20,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                Expanded(
                  child: ProjectsList(
                    searchQuery: query,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
