
part of 'UsersBloc.dart';

abstract class UsersEvent {
  const UsersEvent();
}

/// Cargar todos los usuarios
class UsersFetchAllRequested extends UsersEvent {
  const UsersFetchAllRequested();
}

/// Cargar un usuario por id
class UserRequestedById extends UsersEvent {
  final int userId;

  const UserRequestedById(this.userId);
}

/// Cargar un usuario por email
class UserRequestedByEmail extends UsersEvent {
  final String email;

  const UserRequestedByEmail(this.email);
}

/// Actualizar usuario (para editar perfil, etc.)
class UserUpdateRequested extends UsersEvent {
  final UserUpdateRequest updateRequest;

  const UserUpdateRequested(this.updateRequest);
}

/// Eliminar usuario
class UserDeleteRequested extends UsersEvent {
  final int userId;

  const UserDeleteRequested(this.userId);
}
