// lib/features/projects/bloc/projects_event.dart
part of 'ProjectsBloc.dart';

abstract class ProjectsEvent {
  const ProjectsEvent();
}

/// Cargar todos los proyectos
class ProjectsFetchAllRequested extends ProjectsEvent {
  const ProjectsFetchAllRequested();
}

/// Cargar proyectos por miembro (memberId)
class ProjectsFetchByMemberRequested extends ProjectsEvent {
  final int memberId;

  const ProjectsFetchByMemberRequested(this.memberId);
}

/// Cargar proyectos por leaderId
class ProjectsFetchByLeaderRequested extends ProjectsEvent {
  final int leaderId;

  const ProjectsFetchByLeaderRequested(this.leaderId);
}

/// Cargar proyecto puntual por id
class ProjectRequestedById extends ProjectsEvent {
  final int projectId;

  const ProjectRequestedById(this.projectId);
}

/// Crear un nuevo proyecto
class ProjectCreateRequested extends ProjectsEvent {
  final ProjectCreateRequest request;

  const ProjectCreateRequested(this.request);
}

/// Actualizar un proyecto existente
class ProjectUpdateRequested extends ProjectsEvent {
  final int id;
  final ProjectUpdateRequest request;

  const ProjectUpdateRequested({
    required this.id,
    required this.request,
  });
}

/// Eliminar un proyecto
class ProjectDeleteRequested extends ProjectsEvent {
  final int id;

  const ProjectDeleteRequested(this.id);
}

/// Unirse a un proyecto mediante key
class ProjectJoinByKeyRequested extends ProjectsEvent {
  final String key;

  const ProjectJoinByKeyRequested(this.key);
}

/// Asignar/actualizar código del proyecto
class ProjectCodeSetRequested extends ProjectsEvent {
  final int projectId;
  final String code;

  const ProjectCodeSetRequested({
    required this.projectId,
    required this.code,
  });
}

/// Quitar un miembro de un proyecto
class ProjectMemberRemoveRequested extends ProjectsEvent {
  final int projectId;
  final int memberId;

  const ProjectMemberRemoveRequested({
    required this.projectId,
    required this.memberId,
  });
}
