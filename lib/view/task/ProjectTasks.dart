import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/Tasks/TasksBloc.dart';
import '../../models/projects/ProjectDto.dart';
import '../../sharedPreferences/TaskmasterPrefs.dart';
import 'TasksKanbanView.dart';

class ProjectTasks extends StatefulWidget {
  final ProjectDto project;

  const ProjectTasks({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<ProjectTasks> createState() => _ProjectTasksState();
}

class _ProjectTasksState extends State<ProjectTasks> {
  String query = "";
  int? _userId;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndTasks();
  }

  Future<void> _loadUserIdAndTasks() async {
    try {
      final prefs = await TaskmasterPrefs().init();
      final userId = await prefs.getUserId();

      if (userId != null) {
        setState(() {
          _userId = userId;
        });

        context.read<TasksBloc>().add(
          TasksFetchByProjectAndUserRequested(
            projectId: widget.project.id,
            userId: userId,
          ),
        );
      }
    } catch (e) {
      print('Error cargando userId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                widget.project.name,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTab('Tareas', 0, colorScheme, textTheme),
                  _buildTab('Estadísticas', 1, colorScheme, textTheme),
                  _buildTab('Ajustes', 2, colorScheme, textTheme),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      child: TextField(
                        onChanged: (value) => setState(() => query = value),
                        decoration: InputDecoration(
                          hintText: "Buscar tareas",
                          hintStyle: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor: colorScheme.secondaryContainer,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Image.asset(
                      'assets/img/ic_filter.png',
                      width: 24,
                      height: 24,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () {
                      // Lógica del filtro
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: BlocBuilder<TasksBloc, TasksState>(
                  builder: (context, tasksState) {
                    if (tasksState is TasksLoadInProgress) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (tasksState is TasksFailure) {
                      return Center(
                        child: Text(
                          'Error: ${tasksState.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (tasksState is TasksLoadSuccess) {
                      return TasksKanbanView(
                        tasks: tasksState.tasks,
                        searchQuery: query,
                      );
                    }

                    return const Center(
                      child: Text('No hay tareas', style: TextStyle(color: Colors.grey)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index, ColorScheme colorScheme, TextTheme textTheme) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
