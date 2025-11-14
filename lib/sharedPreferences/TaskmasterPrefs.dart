// dart
import 'package:shared_preferences/shared_preferences.dart';

class TaskmasterPrefs {
  SharedPreferences? _prefs;

  String email = "";
  String password = "";
  String token = "";

  static const _keyEmail = "email";
  static const _keyPassword = "password";
  static const _keyToken = "token";

  Future<TaskmasterPrefs> init() async {
    _prefs ??= await SharedPreferences.getInstance();

    email = _prefs?.getString(_keyEmail) ?? "";
    password = _prefs?.getString(_keyPassword) ?? "";
    token = _prefs?.getString(_keyToken) ?? "";

    return this;
  }


  String getEmail() => email;
  String getPassword() => password;


  Future<String> getEmailAsync() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs?.getString(_keyEmail) ?? email;
  }

  Future<String> getPasswordAsync() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs?.getString(_keyPassword) ?? password;
  }

  Future<void> saveAll({
    required String email,
    required String password,
    required String token,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();

    this.email = email;
    this.password = password;
    this.token = token;

    await _prefs?.setString(_keyEmail, email);
    await _prefs?.setString(_keyPassword, password);
    await _prefs?.setString(_keyToken, token);
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
    await _prefs?.remove(_keyEmail);
    await _prefs?.remove(_keyPassword);
    await _prefs?.remove(_keyToken);
  }
}
