import '../../models/user/UserDto.dart';
import '../../models/user/UserUpdateRequest.dart';
import '../../repository/UsersRepository.dart';
import 'dart:async';
import 'package:bloc/bloc.dart';

part 'UsersEvent.dart';
part 'UsersState.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepository _repository;

  UsersBloc({UsersRepository? repository})
      : _repository = repository ?? UsersRepository(),
        super(UsersInitial()) {
    on<UsersFetchAllRequested>(_onFetchAllRequested);
    on<UserRequestedById>(_onUserRequestedById);
    on<UserRequestedByEmail>(_onUserRequestedByEmail);
    on<UserUpdateRequested>(_onUserUpdateRequested);
    on<UserDeleteRequested>(_onUserDeleteRequested);
  }

  Future<void> _onFetchAllRequested(
      UsersFetchAllRequested event,
      Emitter<UsersState> emit,
      ) async {
    emit(UsersLoadInProgress());
    try {
      final users = await _repository.getAll();
      emit(UsersLoadSuccess(users: users));
    } catch (e) {
      emit(UsersFailure(message: e.toString()));
    }
  }

  Future<void> _onUserRequestedById(
      UserRequestedById event,
      Emitter<UsersState> emit,
      ) async {
    emit(UsersLoadInProgress());
    try {
      final user = await _repository.getById(event.userId);
      emit(UserLoadSuccess(user: user));
    } catch (e) {
      emit(UsersFailure(message: e.toString()));
    }
  }

  Future<void> _onUserRequestedByEmail(
      UserRequestedByEmail event,
      Emitter<UsersState> emit,
      ) async {
    emit(UsersLoadInProgress());
    try {
      final user = await _repository.getByEmail(event.email);
      emit(UserLoadSuccess(user: user));
    } catch (e) {
      emit(UsersFailure(message: e.toString()));
    }
  }

  Future<void> _onUserUpdateRequested(
      UserUpdateRequested event,
      Emitter<UsersState> emit,
      ) async {
    emit(UsersLoadInProgress());
    try {
      final updatedUser = await _repository.update(event.updateRequest);
      emit(UserUpdateSuccess(user: updatedUser));
    } catch (e) {
      emit(UsersFailure(message: e.toString()));
    }
  }

  Future<void> _onUserDeleteRequested(
      UserDeleteRequested event,
      Emitter<UsersState> emit,
      ) async {
    emit(UsersLoadInProgress());
    try {
      await _repository.delete(event.userId);
      emit(UserDeleteSuccess());
    } catch (e) {
      emit(UsersFailure(message: e.toString()));
    }
  }
}
