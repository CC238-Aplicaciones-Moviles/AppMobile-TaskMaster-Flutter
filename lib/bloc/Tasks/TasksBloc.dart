// lib/features/tasks/bloc/tasks_bloc.dart

import 'package:bloc/bloc.dart';

import '../../models/tasks/TaskDto.dart';
import '../../models/tasks/TaskRequest.dart';
import '../../repository/TasksRepository.dart';

part 'TasksEvent.dart';
part 'TasksState.dart';

class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TasksRepository _repository;

  TasksBloc({TasksRepository? repository})
      : _repository = repository ?? TasksRepository(),
        super(TasksInitial()) {
    on<TasksFetchAllRequested>(_onFetchAllRequested);
    on<TasksFetchByUserRequested>(_onFetchByUserRequested);
    on<TasksFetchByProjectRequested>(_onFetchByProjectRequested);
    on<TasksFetchByProjectAndUserRequested>(
        _onFetchByProjectAndUserRequested);
    on<TasksFetchByProjectAndStatusRequested>(
        _onFetchByProjectAndStatusRequested);
    on<TasksFetchByProjectAndPriorityRequested>(
        _onFetchByProjectAndPriorityRequested);

    on<TaskRequestedById>(_onTaskRequestedById);
    on<TaskCreateRequested>(_onTaskCreateRequested);
    on<TaskUpdateRequested>(_onTaskUpdateRequested);
    on<TaskDeleteRequested>(_onTaskDeleteRequested);
    on<TaskAssignRequested>(_onTaskAssignRequested);
    on<TaskUnassignRequested>(_onTaskUnassignRequested);
    on<TaskStatusUpdateRequested>(_onTaskStatusUpdateRequested);
  }

  Future<void> _onFetchAllRequested(
      TasksFetchAllRequested event,
      Emitter<TasksState> emit,
      ) async {
    emit(TasksLoadInProgress());
    try {
      final tasks = await _repository.getAll();
      emit(TasksLoadSuccess(tasks: tasks));
    } catch (e) {
      emit(TasksFailure(message: e.toString()));
    }
  }

  Future<void> _onFetchByUserRequested(
      TasksFetchByUserRequested event,
      Emitter<TasksState> emit,
      ) async {
    emit(TasksLoadInProgress());
    try {
      final tasks = await _repository.getByUser(event.userId);
      emit(TasksLoadSuccess(tasks: tasks));
    } catch (e) {
      emit(TasksFailure(message: e.toString()));
    }
  }

  Future<void> _onFetchByProjectRequested(
      TasksFetchByProjectRequested event,
      Emitter<TasksState> emit,
      ) async {
    emit(TasksLoadInProgress());
    try {
      final tasks = await _repository.getByProject(event.projectId);
      emit(TasksLoadSuccess(tasks: tasks));
    } catch (e) {
      emit(TasksFailure(message: e.toString()));
    }
  }

  Future<void> _onFetchByProjectAndUserRequested(
      TasksFetchByProjectAndUserRequested event,
      Emitter<TasksState> emit,
      ) async {
    emit(TasksLoadInProgress());
    try {
      final tasks = await _repository.getByProjectAndUser(
        event.projectId,
        event.userId,
      );
      emit(TasksLoadSuccess(tasks: tasks));
    } catch (e) {
      emit(TasksFailure(message: e.toString()));
    }
  }

  Future<void> _onFetchByProjectAndStatusRequested(
      TasksFetchByProjectAndStatusRequested event,
      Emitter<TasksState> emit,
      ) async {
    emit(TasksLoadInProgress());
    try {
      final tasks = await _repository.getByProjectAndStatus(
        event.projectId,
        event.status,
      );
      emit(TasksLoadSuccess(tasks: tasks));
    } catch (e) {
      emit(TasksFailure(message: e.toString()));
    }
  }

  Future<void> _onFetchByProjectAndPriorityRequested(
      TasksFetchByProjectAndPriorityRequested event,
      Emitter<TasksState> emit,
      ) async {
    emit(TasksLoadInProgress());
    try {
      final tasks = await _repository.getByProjectAndPriority(
        event.projectId,
        event.priority,
      );
      emit(TasksLoadSuccess(tasks: tasks));
    } catch (e) {
      emit(TasksFailure(message: e.toString()));
    }
  }

  Future<void> _onTaskRequestedById(
      TaskRequestedById event,
      Emitter<TasksState> emit,
      ) async {
    emit(TasksLoadInProgress());
    try {
      final task = await _repository.getById(event.taskId);
      emit(TaskLoadSuccess(task: task));
    } catch (e) {
      emit(TasksFailure(message: e.toString()));
    }
  }

  Future<void> _onTaskCreateRequested(
      TaskCreateRequested event,
      Emitter<TasksState> emit,
      ) async {
    emit(TasksLoadInProgress());
    try {
      final created = await _repository.create(event.request);
      emit(TaskCreateSuccess(task: created));
    } catch (e) {
      emit(TasksFailure(message: e.toString()));
    }
  }

  Future<void> _onTaskUpdateRequested(
      TaskUpdateRequested event,
      Emitter<TasksState> emit,
      ) async {
    emit(TasksLoadInProgress());
    try {
      final updated = await _repository.update(event.taskId, event.request);
      emit(TaskUpdateSuccess(task: updated));
    } catch (e) {
      emit(TasksFailure(message: e.toString()));
    }
  }

  Future<void> _onTaskDeleteRequested(
      TaskDeleteRequested event,
      Emitter<TasksState> emit,
      ) async {
    emit(TasksLoadInProgress());
    try {
      await _repository.delete(event.taskId);
      emit(TaskDeleteSuccess());
    } catch (e) {
      emit(TasksFailure(message: e.toString()));
    }
  }

  Future<void> _onTaskAssignRequested(
      TaskAssignRequested event,
      Emitter<TasksState> emit,
      ) async {
    emit(TasksLoadInProgress());
    try {
      final updated = await _repository.assign(event.taskId, event.userId);
      emit(TaskAssignSuccess(task: updated));
    } catch (e) {
      emit(TasksFailure(message: e.toString()));
    }
  }

  Future<void> _onTaskUnassignRequested(
      TaskUnassignRequested event,
      Emitter<TasksState> emit,
      ) async {
    emit(TasksLoadInProgress());
    try {
      final updated = await _repository.unassign(event.taskId, event.userId);
      emit(TaskUnassignSuccess(task: updated));
    } catch (e) {
      emit(TasksFailure(message: e.toString()));
    }
  }

  Future<void> _onTaskStatusUpdateRequested(
      TaskStatusUpdateRequested event,
      Emitter<TasksState> emit,
      ) async {
    emit(TasksLoadInProgress());
    try {
      final updated =
      await _repository.updateStatus(event.taskId, event.status);
      emit(TaskStatusUpdateSuccess(task: updated));
    } catch (e) {
      emit(TasksFailure(message: e.toString()));
    }
  }
}
