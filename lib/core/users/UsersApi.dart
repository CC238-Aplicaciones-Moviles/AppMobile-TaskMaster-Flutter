
import 'dart:convert';

import '../../models/user/UserDto.dart';
import '../../models/user/UserUpdateRequest.dart';
import '../api_client.dart';

class UsersApi {
  final ApiClient _client;

  UsersApi({ApiClient? client}) : _client = client ?? ApiClient();

  /// GET /api/v1/users
  Future<List<UserDto>> getUsers() async {
    final res = await _client.get('api/v1/users');
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => UserDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// PUT /api/v1/users
  Future<UserDto> updateUser(UserUpdateRequest body) async {
    final res = await _client.put(
      'api/v1/users',
      body: body.toJson(),
    );
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return UserDto.fromJson(json);
  }

  /// GET /api/v1/users/{userId}
  Future<UserDto> getUserById(int userId) async {
    final res = await _client.get('api/v1/users/$userId');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return UserDto.fromJson(json);
  }

  /// DELETE /api/v1/users/{userId}
  Future<void> deleteUser(int userId) async {
    await _client.delete('api/v1/users/$userId');
  }

  /// GET /api/v1/users/email/{email}
  Future<UserDto> getUserByEmail(String email) async {
    final res = await _client.get('api/v1/users/email/$email');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return UserDto.fromJson(json);
  }
}
