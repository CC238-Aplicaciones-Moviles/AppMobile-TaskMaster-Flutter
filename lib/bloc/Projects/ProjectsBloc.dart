
import 'package:bloc/bloc.dart';

import '../../models/projects/ProjectDto.dart';
import '../../models/projects/ProjectRequest.dart';
import '../../repository/ProjectsRepository.dart';
part 'ProjectsEvent.dart';
part 'ProjectsState.dart';


class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ProjectsRepository _repository;

  ProjectsBloc({ProjectsRepository? repository})
      : _repository = repository ?? ProjectsRepository(),
        super(ProjectsInitial()) {
    on<ProjectsFetchAllRequested>(_onFetchAllRequested);
    on<ProjectsFetchByMemberRequested>(_onFetchByMemberRequested);
    on<ProjectsFetchByLeaderRequested>(_onFetchByLeaderRequested);
    on<ProjectRequestedById>(_onProjectRequestedById);
    on<ProjectCreateRequested>(_onProjectCreateRequested);
    on<ProjectUpdateRequested>(_onProjectUpdateRequested);
    on<ProjectDeleteRequested>(_onProjectDeleteRequested);
    on<ProjectJoinByKeyRequested>(_onProjectJoinByKeyRequested);
    on<ProjectCodeSetRequested>(_onProjectCodeSetRequested);
    on<ProjectMemberRemoveRequested>(_onProjectMemberRemoveRequested);
  }

  Future<void> _onFetchAllRequested(
      ProjectsFetchAllRequested event,
      Emitter<ProjectsState> emit,
      ) async {
    emit(ProjectsLoadInProgress());
    try {
      final projects = await _repository.getAll();
      emit(ProjectsLoadSuccess(projects: projects));
    } catch (e) {
      emit(ProjectsFailure(message: e.toString()));
    }
  }

  Future<void> _onFetchByMemberRequested(
      ProjectsFetchByMemberRequested event,
      Emitter<ProjectsState> emit,
      ) async {
    emit(ProjectsLoadInProgress());
    try {
      final projects = await _repository.getByMember(event.memberId);
      emit(ProjectsLoadSuccess(projects: projects));
    } catch (e) {
      emit(ProjectsFailure(message: e.toString()));
    }
  }

  Future<void> _onFetchByLeaderRequested(
      ProjectsFetchByLeaderRequested event,
      Emitter<ProjectsState> emit,
      ) async {
    emit(ProjectsLoadInProgress());
    try {
      final projects = await _repository.getByLeader(event.leaderId);
      emit(ProjectsLoadSuccess(projects: projects));
    } catch (e) {
      emit(ProjectsFailure(message: e.toString()));
    }
  }

  Future<void> _onProjectRequestedById(
      ProjectRequestedById event,
      Emitter<ProjectsState> emit,
      ) async {
    emit(ProjectsLoadInProgress());
    try {
      final project = await _repository.getById(event.projectId);
      emit(ProjectLoadSuccess(project: project));
    } catch (e) {
      emit(ProjectsFailure(message: e.toString()));
    }
  }

  Future<void> _onProjectCreateRequested(
      ProjectCreateRequested event,
      Emitter<ProjectsState> emit,
      ) async {
    emit(ProjectsLoadInProgress());
    try {
      final created = await _repository.create(event.request);
      emit(ProjectCreateSuccess(project: created));
    } catch (e) {
      emit(ProjectsFailure(message: e.toString()));
    }
  }

  Future<void> _onProjectUpdateRequested(
      ProjectUpdateRequested event,
      Emitter<ProjectsState> emit,
      ) async {
    emit(ProjectsLoadInProgress());
    try {
      final updated = await _repository.update(event.id, event.request);
      emit(ProjectUpdateSuccess(project: updated));
    } catch (e) {
      emit(ProjectsFailure(message: e.toString()));
    }
  }

  Future<void> _onProjectDeleteRequested(
      ProjectDeleteRequested event,
      Emitter<ProjectsState> emit,
      ) async {
    emit(ProjectsLoadInProgress());
    try {
      await _repository.delete(event.id);
      emit(ProjectDeleteSuccess());
    } catch (e) {
      emit(ProjectsFailure(message: e.toString()));
    }
  }

  Future<void> _onProjectJoinByKeyRequested(
      ProjectJoinByKeyRequested event,
      Emitter<ProjectsState> emit,
      ) async {
    emit(ProjectsLoadInProgress());
    try {
      final project = await _repository.joinByKey(event.key);
      emit(ProjectJoinSuccess(project: project));
    } catch (e) {
      emit(ProjectsFailure(message: e.toString()));
    }
  }

  Future<void> _onProjectCodeSetRequested(
      ProjectCodeSetRequested event,
      Emitter<ProjectsState> emit,
      ) async {
    emit(ProjectsLoadInProgress());
    try {
      final project = await _repository.setCode(event.projectId, event.code);
      emit(ProjectCodeSetSuccess(project: project));
    } catch (e) {
      emit(ProjectsFailure(message: e.toString()));
    }
  }

  Future<void> _onProjectMemberRemoveRequested(
      ProjectMemberRemoveRequested event,
      Emitter<ProjectsState> emit,
      ) async {
    emit(ProjectsLoadInProgress());
    try {
      await _repository.removeMember(event.projectId, event.memberId);
      emit(ProjectMemberRemovedSuccess());
    } catch (e) {
      emit(ProjectsFailure(message: e.toString()));
    }
  }
}
