
import '../core/auth/AuthApi.dart';
import '../core/auth/TokenStore.dart';
import '../models/auth/LoginRequest.dart';
import '../models/auth/SignUpRequest.dart';
import '../models/user/UserDto.dart';

class AuthRepository {
  final AuthApi _api;

  AuthRepository({AuthApi? api}) : _api = api ?? AuthApi();

  Future<String> signIn(String email, String password) async {
    final res = await _api.signIn(
      LoginRequest(email: email, password: password),
    );
    await TokenStore.saveToken(res.token);
    return res.token;
  }

  Future<UserDto> signUpWithUsername(
      String username, String email, String password) {
    final parts = username.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final name = parts.isNotEmpty ? parts.first : 'Usuario';
    final lastName =
    parts.length > 1 ? parts.sublist(1).join(' ') : 'Nuevo';

    final body = SignUpRequest(
      name: name,
      lastName: lastName,
      email: email,
      password: password,
      roles: const ['ROLE_MEMBER'],
    );
    return _api.signUp(body);
  }
}
