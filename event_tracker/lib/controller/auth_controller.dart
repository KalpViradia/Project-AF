import 'package:get/get.dart';
import '../model/user/user_model.dart';
import '../service/auth_service.dart';
import '../service/storage_service.dart';
import '../service/auto_login_service.dart';
import '../utils/modern_snackbar.dart';
import '../utils/routes.dart';
import '../controller/user_controller.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  final currentUser = Rxn<UserModel>();
  final token = Rxn<String>();
  final isLoggedIn = false.obs;
  final isLoading = false.obs;
  final error = Rxn<String>();

  AuthController({AuthService? authService}) : _authService = authService ?? AuthService();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      isLoading.value = true;
      
      print('🔍 Starting auth status check...');
      
      // Hard gate: if force-logout flag is set, never auto-login until next manual login
      final forced = await StorageService.getForceLogout();
      if (forced) {
        print('🛑 Force-logout flag detected - skipping any auto-login');
        isLoggedIn.value = false;
        currentUser.value = null;
        return;
      }
      
      // 1) Respect Remember Me and try local-token based auto-login path first
      final remember = await StorageService.getRememberMe();
      print('📋 Remember Me enabled: $remember');
      
      if (remember) {
        print('🔑 Attempting auto-login...');
        final success = await _authService.tryAutoLogin();
        print('✅ Auto-login success: $success');
        
        if (success) {
          // Fetch current user using the active token
          print('👤 Fetching current user...');
          final user = await _authService.getCurrentUser();
          print('👤 Current user fetched: ${user?.name ?? 'null'}');
          
          if (user != null) {
            currentUser.value = user;
            isLoggedIn.value = true;
            
            // Also propagate token to AuthController for Dio interceptors
            final localToken = await StorageService.getToken();
            if (localToken != null && localToken.isNotEmpty) {
              token.value = localToken;
              print('🔐 Token set in AuthController');
            }
            
            // Update UserController's current user
            final userController = Get.find<UserController>();
            userController.setCurrentUser(user);
            print('🎯 UserController updated with user: ${user.name}');
            return;
          } else {
            print('❌ User data is null despite successful auto-login');
          }
        }
      }

      // If Remember Me is disabled, do NOT auto-login or try any fallback
      if (!remember) {
        print('🚫 Remember Me disabled - skipping auto-login and fallback');
        isLoggedIn.value = false;
        currentUser.value = null;
        return;
      }

      // 2) Fallback: server-validated auto-login service (if backend supports it)
      print('🔄 Trying fallback AutoLoginService...');
      final autoLoginResult = await AutoLoginService.checkAutoLogin();
      print('📡 AutoLoginService result: $autoLoginResult');
      
      if (autoLoginResult['success'] == true && autoLoginResult['isLoggedIn'] == true) {
        final userData = autoLoginResult['user'];
        if (userData != null) {
          print('👤 Setting user from AutoLoginService: ${userData['name'] ?? userData['Name']}');
          currentUser.value = UserModel.fromJson(userData);
          isLoggedIn.value = true;
          final localToken = await StorageService.getToken();
          if (localToken != null && localToken.isNotEmpty) {
            token.value = localToken;
          }
          final userController = Get.find<UserController>();
          userController.setCurrentUser(currentUser.value!);
          print('🎯 UserController updated via fallback');
          return;
        }
      }
      
      // Auto-login failed, user needs to login manually
      print('❌ All auto-login attempts failed');
      isLoggedIn.value = false;
      currentUser.value = null;
    } catch (e) {
      print('❌ Error checking auth status: $e');
      print('Stack trace: ${StackTrace.current}');
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
      print('Login successful, setting state...');
      currentUser.value = response.user;
      token.value = response.token;
      isLoggedIn.value = true;

      // Respect Remember Me: persist only when enabled, otherwise ensure cleared
      final remember = await StorageService.getRememberMe();
      if (remember) {
        // Save login data to SharedPreferences (services storage)
        await StorageService.saveLoginData(
          token: response.token,
          user: response.user.toJson(),
        );
      } else {
        // Ensure any previously stored auto-login data is cleared
        await StorageService.clearLoginData();
      }

      // Clear any previous force-logout guard now that user manually logged in
      await StorageService.setForceLogout(false);

      // Update UserController's current user
      final userController = Get.find<UserController>();
      userController.setCurrentUser(response.user);

      print('Navigating to home page...');
      await Get.offAllNamed(ROUTE_HOME);
      print('Navigation complete');
    } catch (e) {
      error.value = e.toString();
      // Let the UI layer show the appropriate snackbar message
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String name, String email, String password, {String? phone, String? countryCode}) async {
    try {
      isLoading.value = true;
      error.value = null;

      final response = await _authService.register(
        name,
        email,
        password,
        phone: phone,
        countryCode: countryCode,
      );
      currentUser.value = response.user;
      token.value = response.token;
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

      // Server logout and clear all persisted auth data
      await _authService.logout(); // clears CoreStorage token and preferences
      await StorageService.clearLoginData(); // clears services storage

      // Suppress next auto-login regardless of Remember Me by setting a one-time force-logout flag
      await StorageService.setForceLogout(true);

      // Explicitly reset reactive state
      currentUser.value = null;
      token.value = null;
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

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      isLoading.value = true;
      error.value = null;

      final response = await _authService.updateProfile(updatedUser);
      currentUser.value = response;

      // Sync with UserController
      final userController = Get.find<UserController>();
      userController.setCurrentUser(response);

      // Force UI update
      update();

      // Don't show snackbar here - let the UI handle it to avoid navigation conflicts
    } catch (e) {
      error.value = e.toString();
      rethrow; // Re-throw to handle in UI
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    isLoading.value = true;
    try {
      await _authService.forgotPassword(email);
      // Navigate to reset password page instead of showing snackbar
      Get.toNamed(ROUTE_RESET_PASSWORD, arguments: {'email': email});
    } catch (e) {
      ModernSnackbar.error(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password with token
  Future<void> resetPassword(String token, String newPassword) async {
    isLoading.value = true;
    try {
      await _authService.resetPassword(token, newPassword);
      ModernSnackbar.success(
        title: 'Password Reset',
        message: 'Your password has been reset successfully',
      );
      Get.offAllNamed(ROUTE_LOGIN);
    } catch (e) {
      ModernSnackbar.error(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update password directly (without old password)
  Future<void> updatePasswordDirect(String newPassword) async {
    isLoading.value = true;
    try {
      await _authService.updatePasswordDirect(newPassword);
      ModernSnackbar.success(
        title: 'Password Updated',
        message: 'Your password has been updated successfully',
      );
    } catch (e) {
      ModernSnackbar.error(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password directly with email and new password (simplified flow)
  Future<bool> resetPasswordDirect(String email, String newPassword) async {
    isLoading.value = true;
    try {
      // Use the simplified API endpoint that handles both email verification and password reset
      await _authService.resetPasswordDirect(email, newPassword);
      
      ModernSnackbar.success(
        title: 'Password Reset',
        message: 'Your password has been reset successfully',
      );
      return true;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}