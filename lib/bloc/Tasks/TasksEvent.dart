// lib/features/tasks/bloc/tasks_event.dart
part of 'TasksBloc.dart';

abstract class TasksEvent {
  const TasksEvent();
}

/// Cargar todas las tareas
class TasksFetchAllRequested extends TasksEvent {
  const TasksFetchAllRequested();
}

/// Cargar tareas por usuario
class TasksFetchByUserRequested extends TasksEvent {
  final int userId;

  const TasksFetchByUserRequested(this.userId);
}

/// Cargar tareas por proyecto
class TasksFetchByProjectRequested extends TasksEvent {
  final int projectId;

  const TasksFetchByProjectRequested(this.projectId);
}

/// Cargar tareas por proyecto y usuario
class TasksFetchByProjectAndUserRequested extends TasksEvent {
  final int projectId;
  final int userId;

  const TasksFetchByProjectAndUserRequested({
    required this.projectId,
    required this.userId,
  });
}

/// Cargar tareas por proyecto y status
class TasksFetchByProjectAndStatusRequested extends TasksEvent {
  final int projectId;
  final String status; // "TO_DO", "IN_PROGRESS", etc.

  const TasksFetchByProjectAndStatusRequested({
    required this.projectId,
    required this.status,
  });
}

/// Cargar tareas por proyecto y prioridad
class TasksFetchByProjectAndPriorityRequested extends TasksEvent {
  final int projectId;
  final String priority; // "LOW", "MEDIUM", "HIGH"

  const TasksFetchByProjectAndPriorityRequested({
    required this.projectId,
    required this.priority,
  });
}

/// Cargar una tarea puntual por id
class TaskRequestedById extends TasksEvent {
  final int taskId;

  const TaskRequestedById(this.taskId);
}

/// Crear una tarea
class TaskCreateRequested extends TasksEvent {
  final TaskCreateRequest request;

  const TaskCreateRequested(this.request);
}

/// Actualizar una tarea
class TaskUpdateRequested extends TasksEvent {
  final int taskId;
  final TaskUpdateRequest request;

  const TaskUpdateRequested({
    required this.taskId,
    required this.request,
  });
}

/// Eliminar una tarea
class TaskDeleteRequested extends TasksEvent {
  final int taskId;

  const TaskDeleteRequested(this.taskId);
}

/// Asignar tarea a usuario
class TaskAssignRequested extends TasksEvent {
  final int taskId;
  final int userId;

  const TaskAssignRequested({
    required this.taskId,
    required this.userId,
  });
}

/// Quitar asignación de usuario a la tarea
class TaskUnassignRequested extends TasksEvent {
  final int taskId;
  final int userId;

  const TaskUnassignRequested({
    required this.taskId,
    required this.userId,
  });
}

/// Actualizar estado de la tarea
class TaskStatusUpdateRequested extends TasksEvent {
  final int taskId;
  final String status; // "TO_DO", "DONE", etc.

  const TaskStatusUpdateRequested({
    required this.taskId,
    required this.status,
  });
}
