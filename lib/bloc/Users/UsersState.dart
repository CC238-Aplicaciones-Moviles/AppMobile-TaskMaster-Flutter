part of 'UsersBloc.dart';


abstract class UsersState {
  const UsersState();
}

/// Para estados tipo "acciones" puntuales (snackbar, navegación, etc.)
abstract class UsersActionState extends UsersState {
  const UsersActionState();
}

/// Estado inicial
class UsersInitial extends UsersState {
  const UsersInitial();
}

/// Cargando (lista o usuario puntual)
class UsersLoadInProgress extends UsersState {
  const UsersLoadInProgress();
}

/// Lista de usuarios cargada correctamente
class UsersLoadSuccess extends UsersState {
  final List<UserDto> users;

  const UsersLoadSuccess({required this.users});
}

/// Usuario puntual cargado correctamente
class UserLoadSuccess extends UsersState {
  final UserDto user;

  const UserLoadSuccess({required this.user});
}

/// Error genérico
class UsersFailure extends UsersState {
  final String message;

  const UsersFailure({required this.message});
}

/// Usuario actualizado (acción)
class UserUpdateSuccess extends UsersActionState {
  final UserDto user;

  const UserUpdateSuccess({required this.user});
}

/// Usuario eliminado (acción)
class UserDeleteSuccess extends UsersActionState {
  const UserDeleteSuccess();
}
