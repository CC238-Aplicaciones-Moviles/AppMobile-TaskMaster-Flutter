import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/Tasks/TasksBloc.dart';
import '../../models/projects/ProjectDto.dart';
import '../../sharedPreferences/TaskmasterPrefs.dart';
import 'TasksKanbanView.dart';
import 'package:taskmaster_flutter/view/task/ProjectMembers.dart'; // nueva importación (package)
import 'package:taskmaster_flutter/repository/UsersRepository.dart';
import 'package:taskmaster_flutter/models/user/UserDto.dart';

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
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.project.name,
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onBackground,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Miembros',
                    icon: Icon(Icons.group, color: colorScheme.onBackground),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProjectMembers(
                            project: widget.project,
                            currentUserId: _userId,
                          ),
                        ),
                      );
                    },
                  ),
                ],
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

            // Mostrar barra de búsqueda solo si NO estamos en la pestaña Ajustes
            if (_selectedTabIndex != 2)
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
                              color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
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
            if (_selectedTabIndex == 2)
              const SizedBox(height: 6),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: _buildContent(context),
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

  Widget _buildContent(BuildContext context) {
    // Devuelve el contenido dependiendo de la pestaña seleccionada
    if (_selectedTabIndex == 0) {
      // Tareas: mantener el comportamiento actual (usa TasksBloc)
      return BlocBuilder<TasksBloc, TasksState>(
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
      );
    }

    if (_selectedTabIndex == 1) {
      // Estadísticas (placeholder simple)
      return _buildStatisticsView();
    }

    // Ajustes
    return _buildSettingsView();
  }

  Widget _buildStatisticsView() {
    // Mostrar solo el encabezado de estadísticas (sin el placeholder)
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text('Estadísticas del proyecto', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          // Contenido de estadísticas eliminado para dejar la vista limpia
        ],
      ),
    );
  }

  Widget _buildSettingsView() {
    // Mostrar la imagen grande del proyecto y una card con los campos en filas (sin mostrar el código)
    final p = widget.project;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Imagen circular grande centrada
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                image: p.imageUrl != null && p.imageUrl!.isNotEmpty
                    ? DecorationImage(image: NetworkImage(p.imageUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: p.imageUrl == null || p.imageUrl!.isEmpty
                  ? const Center(child: Icon(Icons.image, size: 40, color: Colors.grey))
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // Card con bordes y filas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha((0.6 * 255).round())),
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nombre
                  _settingsRow(
                    label: 'Nombre del proyecto',
                    child: Row(
                      children: [
                        Expanded(child: Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                  _dividerLine(),

                  // Descripción
                  _settingsRow(
                    label: 'Descripción',
                    child: Row(
                      children: [
                        Expanded(child: Text(p.description, softWrap: true)),
                      ],
                    ),
                  ),
                  _dividerLine(),

                  // Pertenece (líder) -- cargamos user
                  FutureBuilder<UserDto>(
                    future: UsersRepository().getById(p.leaderId),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return _settingsRow(label: 'Pertenece', child: Row(children: const [SizedBox(width: 8), CircularProgressIndicator()]));
                      }
                      if (snap.hasError || !snap.hasData) {
                        return _settingsRow(label: 'Pertenece', child: Text('Usuario ${p.leaderId}'));
                      }
                      final leader = snap.data!;
                      final leaderName = ('${leader.name} ${leader.lastName}').trim();
                      return _settingsRow(
                        label: 'Pertenece',
                        child: Row(
                          children: [
                            Expanded(child: Text(leaderName.isNotEmpty ? leaderName : 'Sin nombre')),
                            if (leader.imageUrl != null && leader.imageUrl!.isNotEmpty)
                              ClipOval(
                                child: Image.network(leader.imageUrl!, width: 36, height: 36, fit: BoxFit.cover),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  _dividerLine(),

                  // Presupuesto
                  _settingsRow(
                    label: 'Presupuesto',
                    child: Row(children: [Expanded(child: Text('S/ ${p.budget}'))]),
                  ),
                  _dividerLine(),

                  // Estado
                  _settingsRow(
                    label: 'Estado',
                    child: Row(children: [Expanded(child: Text(p.status))]),
                  ),
                  _dividerLine(),

                  // Fechas (dos columnas)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Fecha inicio', style: TextStyle(fontSize: 12, color: Colors.black54)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(child: Text(p.startDate, overflow: TextOverflow.ellipsis)),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                                    onPressed: () {},
                                    icon: const Icon(Icons.calendar_today_outlined, size: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Fecha fin', style: TextStyle(fontSize: 12, color: Colors.black54)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(child: Text(p.endDate, overflow: TextOverflow.ellipsis)),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                                    onPressed: () {},
                                    icon: const Icon(Icons.calendar_today_outlined, size: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _settingsRow({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _dividerLine() {
    return Container(height: 1, color: Theme.of(context).dividerColor);
  }
}
