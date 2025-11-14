
import '../core/users/UsersApi.dart';
import '../models/user/UserDto.dart';
import '../models/user/UserUpdateRequest.dart';

class UsersRepository {
  final UsersApi _api;

  UsersRepository({UsersApi? api}) : _api = api ?? UsersApi();

  /// GET /api/v1/users
  Future<List<UserDto>> getAll() => _api.getUsers();

  /// PUT /api/v1/users
  Future<UserDto> update(UserUpdateRequest body) => _api.updateUser(body);

  /// GET /api/v1/users/{userId}
  Future<UserDto> getById(int userId) => _api.getUserById(userId);

  /// DELETE /api/v1/users/{userId}
  Future<void> delete(int userId) => _api.deleteUser(userId);

  /// GET /api/v1/users/email/{email}
  Future<UserDto> getByEmail(String email) => _api.getUserByEmail(email);
}
