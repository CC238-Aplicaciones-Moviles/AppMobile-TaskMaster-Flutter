part of 'ProjectsBloc.dart';

abstract class ProjectsState {
  const ProjectsState();
}

/// Para estados de acción (snackbar, navegación, etc.)
abstract class ProjectsActionState extends ProjectsState {
  const ProjectsActionState();
}

/// Estado inicial
class ProjectsInitial extends ProjectsState {
  const ProjectsInitial();
}

/// Cargando (lista o proyecto puntual)
class ProjectsLoadInProgress extends ProjectsState {
  const ProjectsLoadInProgress();
}

/// Lista de proyectos cargada ok
class ProjectsLoadSuccess extends ProjectsState {
  final List<ProjectDto> projects;

  const ProjectsLoadSuccess({required this.projects});
}

/// Proyecto puntual cargado ok
class ProjectLoadSuccess extends ProjectsState {
  final ProjectDto project;

  const ProjectLoadSuccess({required this.project});
}

/// Error genérico
class ProjectsFailure extends ProjectsState {
  final String message;

  const ProjectsFailure({required this.message});
}

/// Proyecto creado (acción)
class ProjectCreateSuccess extends ProjectsActionState {
  final ProjectDto project;

  const ProjectCreateSuccess({required this.project});
}

/// Proyecto actualizado (acción)
class ProjectUpdateSuccess extends ProjectsActionState {
  final ProjectDto project;

  const ProjectUpdateSuccess({required this.project});
}

/// Proyecto eliminado (acción)
class ProjectDeleteSuccess extends ProjectsActionState {
  const ProjectDeleteSuccess();
}

/// Unirse por key
class ProjectJoinSuccess extends ProjectsActionState {
  final ProjectDto project;

  const ProjectJoinSuccess({required this.project});
}

/// Código del proyecto actualizado (acción)
class ProjectCodeSetSuccess extends ProjectsActionState {
  final ProjectDto project;

  const ProjectCodeSetSuccess({required this.project});
}

/// Miembro eliminado del proyecto (acción)
class ProjectMemberRemovedSuccess extends ProjectsActionState {
  const ProjectMemberRemovedSuccess();
}
