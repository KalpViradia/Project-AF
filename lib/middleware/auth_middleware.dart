import '../utils/import_export.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    final userController = Get.find<UserController>();

    if (userController.currentUser.value == null || !authController.isLoggedIn.value) {
      return const RouteSettings(name: ROUTE_LOGIN);
    }
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    return page;
  }
}
