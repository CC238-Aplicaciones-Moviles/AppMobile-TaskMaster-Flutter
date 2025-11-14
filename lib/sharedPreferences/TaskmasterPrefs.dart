import 'package:shared_preferences/shared_preferences.dart';

class TaskmasterPrefs {
  SharedPreferences? _prefs;

  String email = "";
  String password = "";
  String token = "";
  int userId = 0;

  static const _keyEmail = "email";
  static const _keyPassword = "password";
  static const _keyToken = "token";
  static const _keyUserId = "userId";

  Future<TaskmasterPrefs> init() async {
    _prefs ??= await SharedPreferences.getInstance();

    email = _prefs?.getString(_keyEmail) ?? "";
    password = _prefs?.getString(_keyPassword) ?? "";
    token = _prefs?.getString(_keyToken) ?? "";
    userId = _prefs?.getInt(_keyUserId) ?? 0;

    return this;
  }


  Future<void> saveAll({
    required String email,
    required String password,
    required String token,
    required int userId,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();

    this.email = email;
    this.password = password;
    this.token = token;
    this.userId = userId;

    await _prefs?.setString(_keyEmail, email);
    await _prefs?.setString(_keyPassword, password);
    await _prefs?.setString(_keyToken, token);
    await _prefs?.setInt(_keyUserId, userId);
  }

  Future<void> saveEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();

    this.email = email;
    this.password = password;

    await _prefs?.setString(_keyEmail, email);
    await _prefs?.setString(_keyPassword, password);
  }

  Future<void> saveToken(String token) async {
    _prefs ??= await SharedPreferences.getInstance();

    this.token = token;
    await _prefs?.setString(_keyToken, token);
  }

  Future<void> saveUserId(int userId) async {
    _prefs ??= await SharedPreferences.getInstance();

    this.userId = userId;
    await _prefs?.setInt(_keyUserId, userId);
  }

  Future<int?> getUserId() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs?.getInt(_keyUserId);
  }

  Future<void> clearUserId() async {
    _prefs ??= await SharedPreferences.getInstance();

    userId = 0;
    await _prefs?.remove(_keyUserId);
  }

  Future<void> clearToken() async {
    _prefs ??= await SharedPreferences.getInstance();

    token = "";
    await _prefs?.remove(_keyToken);
  }

  Future<void> clearAll() async {
    _prefs ??= await SharedPreferences.getInstance();

    email = "";
    password = "";
    token = "";
    userId = 0;
    await _prefs?.remove(_keyEmail);
    await _prefs?.remove(_keyPassword);
    await _prefs?.remove(_keyToken);
    await _prefs?.remove(_keyUserId);
  }
}
