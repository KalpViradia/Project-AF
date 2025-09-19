import 'package:get/get.dart';
import '../service/auth_service.dart';
import '../controller/auth_api_controller.dart';

class DependencyInjection {
  static void init() {
    // Services
    Get.lazyPut<AuthService>(
      () => AuthService(),
      fenix: true,
    );

    // Controllers
    Get.lazyPut<AuthApiController>(
      () => AuthApiController(
        authService: Get.find<AuthService>(),
      ),
      fenix: true,
    );
  }
}
