import '../utils/import_export.dart';

class UserController extends GetxController {
  final currentUser = Rxn<UserModel>();
  final RxString nameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;

  bool validateSignupFields(String name, String email, String password) {
    nameError.value = name.isEmpty ? 'Name cannot be empty' : '';
    emailError.value = GetUtils.isEmail(email) ? '' : 'Enter a valid email';
    passwordError.value = password.length >= 6 ? '' : 'Password must be at least 6 characters';

    return nameError.value.isEmpty &&
        emailError.value.isEmpty &&
        passwordError.value.isEmpty;
  }

  bool validateLoginFields(String email, String password) {
    emailError.value = GetUtils.isEmail(email) ? '' : 'Enter a valid email';
    passwordError.value = password.isEmpty ? 'Password cannot be empty' : '';

    return emailError.value.isEmpty &&
        passwordError.value.isEmpty;
  }

  /// Sign up a new user
  Future<void> signupUser(String name, String email, String phone, String password) async {
    final db = await AppDatabase().database;
    final user = UserModel(
      userId: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      createdAt: DateTime.now(), isActive: true,
    );
    await db.insert(TBL_USERS, user.toJson());
    currentUser.value = user;
  }

  /// Legacy login method (not used anymore)
  Future<bool> loginUser(String email, String password) async {
    final user = await getUserByEmailAndPassword(email, password);
    if (user != null) {
      currentUser.value = user;
      return true;
    }
    return false;
  }

  /// 🔍 Get user from DB by email and password
  Future<UserModel?> getUserByEmailAndPassword(String email, String password) async {
    final db = await AppDatabase().database;
    final result = await db.query(
      TBL_USERS,
      where: '$COL_USER_EMAIL = ? AND $COL_USER_PASSWORD = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return UserModel.fromJson(result.first);
    }
    return null;
  }

  /// 🧠 Set current user (called after login)
  void setCurrentUser(UserModel user) {
    currentUser.value = user;
    update(); // Ensure UI updates
  }

  /// 🔐 Clear user on logout
  void clearCurrentUser() {
    currentUser.value = null;
  }

  /// 🧾 Update profile
  Future<void> updateUserProfile(UserModel updatedUser) async {
    final db = await AppDatabase().database;

    await db.update(
      TBL_USERS,
      updatedUser.toJson(),
      where: '$COL_USER_ID = ?',
      whereArgs: [updatedUser.userId],
    );

    currentUser.value = updatedUser;
    update();
  }
}
