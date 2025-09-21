import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/user/user_model.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _rememberMeKey = 'remember_me';
  static const String _forceLogoutKey = 'force_logout';
  static const String _inviteesKey = 'invitees_list';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save complete login response (from services folder approach)
  static Future<void> saveLoginData({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await init();
    await _prefs!.setString(_tokenKey, token);
    await _prefs!.setString(_userKey, jsonEncode(user));
    await _prefs!.setBool(_isLoggedInKey, true);
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

  // User data management (from services folder approach)
  static Future<Map<String, dynamic>?> getUserData() async {
    await init();
    final userJson = _prefs!.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  static Future<void> updateUserData(Map<String, dynamic> user) async {
    await init();
    await _prefs!.setString(_userKey, jsonEncode(user));
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

  // Check if user is logged in (combined approach)
  static Future<bool> isLoggedIn() async {
    await init();
    final token = await getToken();
    final isLoggedInFlag = _prefs!.getBool(_isLoggedInKey) ?? false;
    return (token != null && token.isNotEmpty) || isLoggedInFlag;
  }

  // Clear login data (from services folder approach)
  static Future<void> clearLoginData() async {
    await init();
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_userKey);
    await _prefs!.setBool(_isLoggedInKey, false);
  }

  // Clear all stored data
  static Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }

  // Invitees list management
  static Future<List<UserModel>> getInvitees() async {
    await init();
    final jsonStr = _prefs!.getString(_inviteesKey);
    if (jsonStr == null || jsonStr.isEmpty) return <UserModel>[];
    try {
      final List<dynamic> data = jsonDecode(jsonStr) as List<dynamic>;
      return data
          .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return <UserModel>[];
    }
  }

  static Future<void> saveInvitees(List<UserModel> users) async {
    await init();
    final list = users
        .map((u) => {
              'userId': u.userId,
              'name': u.name,
              'email': u.email,
              'phone': u.phone,
              'address': u.address,
              'dateOfBirth': u.dateOfBirth,
              'gender': u.gender,
              'bio': u.bio,
              'isActive': u.isActive,
              'createdAt': u.createdAt.toIso8601String(),
              'lastLogin': u.lastLogin?.toIso8601String(),
            })
        .toList();
    await _prefs!.setString(_inviteesKey, jsonEncode(list));
  }

  static Future<void> addInvitee(UserModel user) async {
    final list = await getInvitees();
    if (list.any((u) => u.userId == user.userId)) return;
    list.add(user);
    await saveInvitees(list);
  }

  static Future<void> removeInvitee(String userId) async {
    final list = await getInvitees();
    list.removeWhere((u) => u.userId == userId);
    await saveInvitees(list);
  }
}
