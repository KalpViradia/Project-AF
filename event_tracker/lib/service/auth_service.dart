import '../model/auth/auth_response.dart';
import '../model/auth/login_request.dart';
import '../model/auth/register_request.dart';
import '../model/user/user_model.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService({ApiService? apiService})
      : _apiService = apiService ?? ApiService(baseUrl: ApiConstants.baseUrl);

  Future<AuthResponse> login(String email, String password) async {
    try {
      print('Attempting login for email: $email');
      final request = LoginRequest(email: email, password: password);

      final response = await _apiService.post(
        ApiConstants.login,
        body: request.toJson(),
      );

      print('Login API Response: $response');

      if (response == null) {
        throw Exception('No response from server');
      }

      // The response should be a Map with token and user
      final Map<String, dynamic> responseMap = (response is Map)
          ? (response as Map<String, dynamic>)
          : throw Exception('Invalid response format: $response');

      final AuthResponse authResponse;
      if (!responseMap.containsKey('user')) {
        // If there's no user field, treat the response as user data except for the token
        final Map<String, dynamic> userMap = Map<String, dynamic>.from(responseMap);
        userMap.remove('token'); // Remove token from user data

        authResponse = AuthResponse(
          token: responseMap['token'] as String,
          user: UserModel.fromJson(userMap),
        );
      } else {
        // Normal case where we have both token and user
        authResponse = AuthResponse(
          token: responseMap['token'] as String,
          user: UserModel.fromJson(responseMap['user'] as Map<String, dynamic>),
        );
      }

      print('Created AuthResponse: ${authResponse.toJson()}');
      await _apiService.setToken(authResponse.token);

      // Store token and user credentials for auto-login only if remember me is enabled
      final rememberMe = await StorageService.getRememberMe();
      if (rememberMe) {
        await StorageService.saveToken(authResponse.token);
        await StorageService.saveUserCredentials(
          authResponse.user.userId,
          authResponse.user.email
        );
      }

      return authResponse;
    } catch (e, stackTrace) {
      print('Login Error: $e');
      print('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  Future<AuthResponse> register(String name, String email, String password) async {
    final request = RegisterRequest(
      name: name,
      email: email,
      password: password,
    );
    final response = await _apiService.post(
      ApiConstants.signup,
      body: request.toJson(),
    );
    final authResponse = AuthResponse.fromJson(response);
    await _apiService.setToken(authResponse.token);

    // Store token and user credentials for auto-login only if remember me is enabled
    final rememberMe = await StorageService.getRememberMe();
    if (rememberMe) {
      await StorageService.saveToken(authResponse.token);
      await StorageService.saveUserCredentials(
        authResponse.user.userId,
        authResponse.user.email
      );
    }

    return authResponse;
  }

  Future<void> logout() async {
    try {
      // Read any existing token (may be null)
      final token = await _apiService.getToken() ?? await StorageService.getToken();
      // Best-effort notify server to mark user as logged out
      try {
        await _apiService.post(ApiConstants.logout, body: {
          if (token != null) 'token': token,
        });
      } catch (_) {
        // Even if server call fails, proceed with local cleanup
      }

      // Clear API token and local persisted credentials but preserve Remember Me and force-logout
      await _apiService.clearToken();
      // Clear token and user credentials stored in SharedPreferences (core storage)
      await StorageService.clearToken();
      await StorageService.clearUserCredentials();
    } catch (_) {
      // Swallow errors to ensure logout always completes locally
      await _apiService.clearToken();
      await StorageService.clearToken();
      await StorageService.clearUserCredentials();
    }
  }

  Future<UserModel> updateProfile(UserModel user) async {
    try {
      // Create the update request payload
      final updateRequest = {
        'userId': user.userId,
        'name': user.name,
        'phone': user.phone,
        'gender': user.gender,
        'dateOfBirth': user.dateOfBirth,
        'bio': user.bio,
      };

      print('Sending update request: $updateRequest');

      final endpoint = ApiConstants.updateUser.replaceAll('{userId}', user.userId);
      final response = await _apiService.put(
        endpoint,
        body: updateRequest,
      );

      print('Update response: $response');
      return UserModel.fromJson(response);
    } catch (e) {
      print('Update profile error: $e');
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      // First check if we have a stored token
      String? token = await StorageService.getToken();

      if (token == null) {
        // Fallback to API service token
        token = await _apiService.getToken();
      }

      if (token == null) {
        print('🚫 No token found for getCurrentUser');
        return null;
      }

      // Set the token in API service if not already set
      await _apiService.setToken(token);

      print('🌐 Calling /auth/me endpoint...');
      final response = await _apiService.get('/auth/me');
      print('📥 /auth/me response: $response');

      if (response == null) {
        print('❌ /auth/me returned null response');
        return null;
      }

      if (response is! Map) {
        print('❌ /auth/me returned non-object payload');
        return null;
      }

      final map = Map<String, dynamic>.from(response);
      final hasUserId = map.containsKey('userId') || map.containsKey('UserId');
      final hasEmail = map.containsKey('email') || map.containsKey('Email');
      final hasName = map.containsKey('name') || map.containsKey('Name');
      if (!hasUserId || !hasEmail || !hasName) {
        print('❌ /auth/me missing required user fields');
        return null;
      }

      final user = UserModel.fromJson(map);
      print('👤 Parsed user: ${user.name} (${user.email})');
      return user;
    } catch (e) {
      print('❌ getCurrentUser error: $e');
      // Clear both API service and storage tokens on error
      await _apiService.clearToken();
      await StorageService.clearAll();
      return null;
    }
  }

  // Auto-login method using stored credentials
  Future<bool> tryAutoLogin() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return false;

      // Set token and try to get current user
      await _apiService.setToken(token);
      final user = await getCurrentUser();

      return user != null;
    } catch (e) {
      print('Auto-login failed: $e');
      await StorageService.clearAll();
      return false;
    }
  }

  // Forgot password - send reset email
  Future<bool> forgotPassword(String email) async {
    try {
      print('Sending password reset email to: $email');
      final response = await _apiService.post(
        '/Auth/forgot-password',
        body: {'email': email},
      );

      print('Forgot password response: $response');
      return true;
    } catch (e) {
      print('Forgot password error: $e');
      throw Exception('Failed to send password reset email');
    }
  }

  // Reset password with token
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      print('Resetting password with token');
      final response = await _apiService.post(
        '/Auth/reset-password',
        body: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      print('Reset password response: $response');
      return true;
    } catch (e) {
      print('Reset password error: $e');
      throw Exception('Failed to reset password');
    }
  }

  // Update password without old password (for forgot password flow)
  Future<bool> updatePasswordDirect(String newPassword) async {
    try {
      print('Updating password directly');
      final response = await _apiService.put(
        '/Auth/update-password-direct',
        body: {'newPassword': newPassword},
      );

      print('Update password response: $response');
      return true;
    } catch (e) {
      print('Update password error: $e');
      throw Exception('Failed to update password');
    }
  }

  // Reset password directly with email and new password (simplified flow)
  Future<bool> resetPasswordDirect(String email, String newPassword) async {
    try {
      print('Resetting password directly with email: $email');
      final response = await _apiService.post(
        '/Auth/reset-password-direct',
        body: {
          'email': email,
          'newPassword': newPassword,
        },
      );

      print('Reset password direct response: $response');
      return true;
    } catch (e) {
      print('Reset password direct error: $e');
      throw Exception('Failed to reset password');
    }
  }
}
