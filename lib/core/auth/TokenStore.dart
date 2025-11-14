import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static const _keyToken = 'token_taskmaster';
  static String? _inMemoryToken;

  static Future<void> saveToken(String token) async {
    _inMemoryToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    if (_inMemoryToken != null) return _inMemoryToken;
    final prefs = await SharedPreferences.getInstance();
    _inMemoryToken = prefs.getString(_keyToken);
    return _inMemoryToken;
  }

  static Future<void> clearToken() async {
    _inMemoryToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }
}
