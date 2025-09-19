import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _rememberMeKey = 'remember_me';
  static const String _forceLogoutKey = 'force_logout';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Token management
  static Future<void> saveToken(String token) async {
    await init();
    await _prefs!.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    await init();
    return _prefs!.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    await init();
    await _prefs!.remove(_tokenKey);
  }

  // User credentials for auto-login
  static Future<void> saveUserCredentials(String userId, String email) async {
    await init();
    await _prefs!.setString(_userIdKey, userId);
    await _prefs!.setString(_userEmailKey, email);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    await init();
    return {
      'userId': _prefs!.getString(_userIdKey),
      'email': _prefs!.getString(_userEmailKey),
    };
  }

  static Future<void> clearUserCredentials() async {
    await init();
    await _prefs!.remove(_userIdKey);
    await _prefs!.remove(_userEmailKey);
  }

  // Remember me functionality
  static Future<void> setRememberMe(bool remember) async {
    await init();
    await _prefs!.setBool(_rememberMeKey, remember);
  }

  static Future<bool> getRememberMe() async {
    await init();
    return _prefs!.getBool(_rememberMeKey) ?? false;
  }

  // Force logout guard to prevent any auto-login until next manual login
  static Future<void> setForceLogout(bool value) async {
    await init();
    await _prefs!.setBool(_forceLogoutKey, value);
  }

  static Future<bool> getForceLogout() async {
    await init();
    return _prefs!.getBool(_forceLogoutKey) ?? false;
  }

  // Clear all stored data
  static Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
