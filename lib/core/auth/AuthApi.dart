import 'dart:convert';
import 'package:taskmaster_flutter/core/api_client.dart';

import '../../models/auth/LoginRequest.dart';
import '../../models/auth/LoginResponse.dart';
import '../../models/auth/SignUpRequest.dart';
import '../../models/user/UserDto.dart';


class AuthApi {
  final ApiClient _client;

  AuthApi({ApiClient? client}) : _client = client ?? ApiClient();

  Future<LoginResponse> signIn(LoginRequest body) async {
    final res = await _client.post(
      'api/v1/authentication/sign-in',
      body: body.toJson(),
      auth: false,
    );
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return LoginResponse.fromJson(json);
  }

  Future<UserDto> signUp(SignUpRequest body) async {
    final res = await _client.post(
      'api/v1/authentication/sign-up',
      body: body.toJson(),
      auth: false,
    );
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return UserDto.fromJson(json);
  }
}
