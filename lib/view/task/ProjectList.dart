import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/Projects/ProjectsBloc.dart';
import '../../bloc/Tasks/TasksBloc.dart';
import '../../models/projects/ProjectDto.dart';
import '../../sharedPreferences/TaskmasterPrefs.dart';
import 'ProjectCard.dart';
import 'EmptyTask.dart';
import 'ProjectTasks.dart';

class ProjectsList extends StatefulWidget {
  final String searchQuery;

  const ProjectsList({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

  @override
  State<ProjectsList> createState() => _ProjectsListState();
}

class _ProjectsListState extends State<ProjectsList> {
  Map<int, int> _taskCounts = {};
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndTaskCounts();
  }

  Future<void> _loadUserIdAndTaskCounts() async {
    try {
      final prefs = await TaskmasterPrefs().init();
      final userId = await prefs.getUserId();

      if (userId != null) {
        setState(() {
          _currentUserId = userId;
        });

        final tasksBloc = context.read<TasksBloc>();

        tasksBloc.stream.listen((state) {
          if (state is TasksLoadSuccess) {
            _updateTaskCounts(state.tasks, userId);
          }
        });

        if (tasksBloc.state is TasksLoadSuccess) {
          _updateTaskCounts((tasksBloc.state as TasksLoadSuccess).tasks, userId);
        }
      }
    } catch (e) {
      print('Error cargando userId: $e');
    }
  }

  void _updateTaskCounts(List<dynamic> tasks, int userId) {
    final counts = <int, int>{};

    for (var task in tasks) {
      if (task.assignedUserIds.contains(userId)) {
        final projectId = task.projectId;
        counts[projectId] = (counts[projectId] ?? 0) + 1;
      }
    }

    if (mounted) {
      setState(() {
        _taskCounts = counts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsBloc, ProjectsState>(
      builder: (context, projectsState) {
        if (projectsState is ProjectsLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        }

        if (projectsState is ProjectsFailure) {
          return _buildErrorState(projectsState.message, () {
            context.read<ProjectsBloc>().add(ProjectsFetchByMemberRequested());
          });
        }

        if (projectsState is ProjectsLoadSuccess) {
          final projects = projectsState.projects;

          final filteredProjects = widget.searchQuery.isEmpty
              ? projects
              : projects.where((project) =>
          project.name.toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
              project.description.toLowerCase().contains(widget.searchQuery.toLowerCase()))
              .toList();

          if (filteredProjects.isEmpty) {
            return widget.searchQuery.isEmpty
                ? const EmptyTask()
                : const _EmptySearchState();
          }

          return ListView.separated(
            itemCount: filteredProjects.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final project = filteredProjects[index];
              final taskCount = _taskCounts[project.id] ?? 0;

              return ProjectCard(
                project: project,
                taskCount: taskCount,
                onTap: () => _onProjectTap(context, project),
              );
            },
          );
        }

        return const EmptyTask();
      },
    );
  }

  void _onProjectTap(BuildContext context, ProjectDto project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectTasks(project: project),
      ),
    ).then((_) {
      context.read<TasksBloc>().add(TasksFetchAllRequested());
    });
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: colorScheme.error),
        const SizedBox(height: 16),
        Text(
          'Error: $message',
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.error),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onRetry,
          child: const Text('Reintentar'),
        ),
      ],
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 64, color: colorScheme.onSurface.withOpacity(0.4)),
        const SizedBox(height: 16),
        Text(
          'No se encontraron proyectos que coincidan con la búsqueda',
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
        ),
      ],
    );
  }
}
