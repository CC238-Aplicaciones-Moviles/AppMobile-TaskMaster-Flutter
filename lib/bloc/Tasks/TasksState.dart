// lib/features/tasks/bloc/tasks_state.dart
part of 'TasksBloc.dart';

abstract class TasksState {
  const TasksState();
}

/// Para estados de acción (snackbar, navegación, etc.)
abstract class TasksActionState extends TasksState {
  const TasksActionState();
}

/// Estado inicial
class TasksInitial extends TasksState {
  const TasksInitial();
}

/// Cargando (lista o una tarea puntual)
class TasksLoadInProgress extends TasksState {
  const TasksLoadInProgress();
}

/// Lista de tareas cargada correctamente
class TasksLoadSuccess extends TasksState {
  final List<TaskDto> tasks;

  const TasksLoadSuccess({required this.tasks});
}

/// Tarea puntual cargada correctamente
class TaskLoadSuccess extends TasksState {
  final TaskDto task;

  const TaskLoadSuccess({required this.task});
}

/// Error genérico
class TasksFailure extends TasksState {
  final String message;

  const TasksFailure({required this.message});
}

/// Tarea creada (acción)
class TaskCreateSuccess extends TasksActionState {
  final TaskDto task;

  const TaskCreateSuccess({required this.task});
}

/// Tarea actualizada (acción)
class TaskUpdateSuccess extends TasksActionState {
  final TaskDto task;

  const TaskUpdateSuccess({required this.task});
}

/// Tarea eliminada (acción)
class TaskDeleteSuccess extends TasksActionState {
  const TaskDeleteSuccess();
}

/// Tarea asignada (acción)
class TaskAssignSuccess extends TasksActionState {
  final TaskDto task;

  const TaskAssignSuccess({required this.task});
}

/// Tarea desasignada (acción)
class TaskUnassignSuccess extends TasksActionState {
  final TaskDto task;

  const TaskUnassignSuccess({required this.task});
}

/// Estado de tarea actualizado (acción)
class TaskStatusUpdateSuccess extends TasksActionState {
  final TaskDto task;

  const TaskStatusUpdateSuccess({required this.task});
}
