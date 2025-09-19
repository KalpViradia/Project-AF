import 'package:get/get.dart';
import '../model/user/user_model.dart';
import '../service/auth_service.dart';
import '../utils/modern_snackbar.dart';
import '../utils/routes.dart';

class AuthApiController extends GetxController {
  final AuthService _authService;
  final currentUser = Rxn<UserModel>();
  final isLoggedIn = false.obs;
  final isLoading = false.obs;
  final error = Rxn<String>();

  AuthApiController({AuthService? authService}) : _authService = authService ?? AuthService();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      isLoading.value = true;
      final user = await _authService.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
        isLoggedIn.value = true;
      }
    } catch (e) {
      error.value = e.toString();
      isLoggedIn.value = false;
      currentUser.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = null;

      final response = await _authService.login(email, password);
      currentUser.value = response.user;
      isLoggedIn.value = true;

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      error.value = e.toString();
      ModernSnackbar.error(
        title: "Login Failed",
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      error.value = null;

      final response = await _authService.register(name, email, password);
      currentUser.value = response.user;
      isLoggedIn.value = true;

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      error.value = e.toString();
      ModernSnackbar.error(
        title: "Registration Failed",
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      error.value = null;

      await _authService.logout();
      currentUser.value = null;
      isLoggedIn.value = false;

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      error.value = e.toString();
      ModernSnackbar.error(
        title: "Logout Failed",
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}