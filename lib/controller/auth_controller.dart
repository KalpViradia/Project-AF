import '../utils/import_export.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final currentUser = Rxn<UserModel>();
  final isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> autoLogin() async {
    try {
      final userId = await _authService.getLoggedInUserId();
      if (userId != null) {
        final user = await getUserById(userId);
        if (user != null && user.isActive == 1) {
          currentUser.value = user;
          isLoggedIn.value = true;
          // Sync UserController.currentUser
          Get.find<UserController>().currentUser.value = user;
          
          // Update last login time
          final db = await AppDatabase().database;
          await db.update(
            TBL_USERS,
            {COL_USER_LAST_LOGIN: DateTime.now().toIso8601String()},
            where: '$COL_USER_ID = ?',
            whereArgs: [userId],
          );
          
          // Load events for the logged-in user
          await Get.find<EventController>().loadEvents();
          await Get.find<InviteController>().loadInvitedEvents();
          return;
        }
        await _authService.logoutUser();
      }
      isLoggedIn.value = false;
      currentUser.value = null;
    } catch (e) {
      print('Error during auto login: $e');
      isLoggedIn.value = false;
      currentUser.value = null;
    }
  }

  Future<void> login(String email, String password) async {
    final user = await _authService.login(email, password);
    if (user != null) {
      currentUser.value = user;
      isLoggedIn.value = true;
      // Sync UserController.currentUser
      Get.find<UserController>().currentUser.value = user;
      // Clear and reload event/invite lists for new user
      Get.find<EventController>().events.clear();
      Get.find<InviteController>().invitedEvents.clear();
      await Get.find<EventController>().loadEvents();
      await Get.find<InviteController>().loadInvitedEvents();
      Get.offAllNamed(ROUTE_HOME);
    } else {
      Get.snackbar("Login Failed", "Invalid email or password");
    }
  }

  Future<void> signUp(UserModel user) async {
    final newUser = await _authService.signUp(user);
    if (newUser != null) {
      currentUser.value = newUser;
      isLoggedIn.value = true;
      // Sync UserController.currentUser
      Get.find<UserController>().currentUser.value = newUser;
      // Clear and reload event/invite lists for new user
      Get.find<EventController>().events.clear();
      Get.find<InviteController>().invitedEvents.clear();
      await Get.find<EventController>().loadEvents();
      await Get.find<InviteController>().loadInvitedEvents();
      Get.offAllNamed(ROUTE_HOME);
    } else {
      Get.snackbar("Signup Failed", "Could not create user");
    }
  }

  Future<void> logout() async {
    await _authService.logoutUser();
    currentUser.value = null;
    isLoggedIn.value = false;
    // Sync UserController.currentUser
    Get.find<UserController>().currentUser.value = null;
    // Clear event/invite lists on logout
    Get.find<EventController>().events.clear();
    Get.find<InviteController>().invitedEvents.clear();
    Get.offAllNamed(ROUTE_LOGIN);
  }

  Future<UserModel?> getUserById(String userId) async {
    final db = await AppDatabase().database;
    final result = await db.query(
      TBL_USERS,
      where: '$COL_USER_ID = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateUser(UserModel updatedUser) async {
    final db = await AppDatabase().database;
    await db.update(
      TBL_USERS,
      updatedUser.toMap(),
      where: '$COL_USER_ID = ?',
      whereArgs: [updatedUser.userId],
    );
    currentUser.value = updatedUser;
  }
}
