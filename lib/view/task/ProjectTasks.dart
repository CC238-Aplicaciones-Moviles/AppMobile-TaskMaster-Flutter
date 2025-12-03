import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/Tasks/TasksBloc.dart';
import '../../models/projects/ProjectDto.dart';
import '../../models/tasks/TaskDto.dart';
import '../../sharedPreferences/TaskmasterPrefs.dart';
import '../project/ProjectStatistics.dart';
import 'TasksKanbanView.dart';
import 'FiltersDialog.dart';

class ProjectTasks extends StatefulWidget {
  final ProjectDto project;

  const ProjectTasks({
    super.key,
    required this.project,
  });

  @override
  State<ProjectTasks> createState() => _ProjectTasksState();
}

class _ProjectTasksState extends State<ProjectTasks> {
  String query = "";
  int? _userId;
  int _selectedTabIndex = 0;

  String? _activePriority;
  String? _activeStatus;
  DateTime? _activeStartDate;
  DateTime? _activeEndDate;

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
      } else {
        context.read<TasksBloc>().add(
          TasksFetchByProjectRequested(widget.project.id),
        );
      }
    } catch (e) {
      print('Error cargando userId: $e');
    }
  }

  Future<void> _showFiltersDialog() async {
    final result = await FiltersDialog.show(
      context,
      initialPriority: _activePriority,
      initialStatus: _activeStatus,
      initialStart: _activeStartDate,
      initialEnd: _activeEndDate,
    );

    if (result == null) return;

    if (result.cleared) {
      _clearFilters();
      return;
    }

    _applyFilters(
      priority: result.priority,
      status: result.status,
      start: result.start,
      end: result.end,
    );
  }

  void _clearFilters() {
    setState(() {
      _activePriority = null;
      _activeStatus = null;
      _activeStartDate = null;
      _activeEndDate = null;
    });

    if (_userId != null) {
      context.read<TasksBloc>().add(
        TasksFetchByProjectAndUserRequested(
          projectId: widget.project.id,
          userId: _userId!,
        ),
      );
    } else {
      context.read<TasksBloc>().add(
        TasksFetchByProjectRequested(widget.project.id),
      );
    }
  }

  void _applyFilters({
    String? priority,
    String? status,
    DateTime? start,
    DateTime? end,
  }) {
    setState(() {
      _activePriority = priority;
      _activeStatus = status;
      _activeStartDate = start;
      _activeEndDate = end;
    });

    if (_userId != null) {
      context.read<TasksBloc>().add(
        TasksFetchByProjectAndUserRequested(
          projectId: widget.project.id,
          userId: _userId!,
        ),
      );
      return;
    }

    if (priority != null && status == null) {
      context.read<TasksBloc>().add(
        TasksFetchByProjectAndPriorityRequested(
          projectId: widget.project.id,
          priority: priority,
        ),
      );
    } else if (status != null && priority == null) {
      context.read<TasksBloc>().add(
        TasksFetchByProjectAndStatusRequested(
          projectId: widget.project.id,
          status: status,
        ),
      );
    } else if (priority != null && status != null) {
      context.read<TasksBloc>().add(
        TasksFetchByProjectAndPriorityRequested(
          projectId: widget.project.id,
          priority: priority,
        ),
      );
    } else {
      context.read<TasksBloc>().add(
        TasksFetchByProjectRequested(widget.project.id),
      );
    }
  }

  List<TaskDto> _applyLocalFilters(List<TaskDto> tasks) {
    var filtered = tasks;

    if (_activePriority != null) {
      filtered = filtered.where((t) => t.priority.name == _activePriority).toList();
    }

    if (_activeStatus != null) {
      filtered = filtered.where((t) => t.status.name == _activeStatus).toList();
    }

    if (_activeStartDate != null) {
      filtered = filtered.where((t) {
        final sd = DateTime.tryParse(t.startDate);
        if (sd == null) return false;
        return !sd.isBefore(_activeStartDate!);
      }).toList();
    }

    if (_activeEndDate != null) {
      filtered = filtered.where((t) {
        final ed = DateTime.tryParse(t.endDate);
        if (ed == null) return false;
        return !ed.isAfter(_activeEndDate!);
      }).toList();
    }

    return filtered;
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
            if (_selectedTabIndex == 0)
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
                      onPressed: _showFiltersDialog,
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
                      final filteredTasks = _applyLocalFilters(tasksState.tasks);

                      if (_selectedTabIndex == 1) {
                        return ProjectStatistics(tasks: filteredTasks);
                      }
                      return TasksKanbanView(
                        tasks: filteredTasks.where((task) {
                          if (query.isEmpty) return true;
                          final q = query.toLowerCase();
                          return task.title.toLowerCase().contains(q) ||
                              task.description.toLowerCase().contains(q);
                        }).toList(),
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
