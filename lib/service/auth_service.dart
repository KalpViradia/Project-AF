import '../utils/import_export.dart';

class AuthService {
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId');
  }

  Future<String?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> saveUserLogin(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future<UserModel?> login(String email, String password) async {
    final db = await AppDatabase().database;
    final result = await db.query(
      TBL_USERS,
      where: '$COL_USER_EMAIL = ? AND $COL_USER_PASSWORD = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      final user = UserModel.fromMap(result.first);
      await saveUserLogin(user.userId);
      return user;
    }
    return null;
  }

  Future<UserModel?> signUp(UserModel user) async {
    final db = await AppDatabase().database;
    final id = await db.insert(TBL_USERS, user.toMap());
    if (id > 0) {
      await saveUserLogin(user.userId);
      return user;
    }
    return null;
  }
}
