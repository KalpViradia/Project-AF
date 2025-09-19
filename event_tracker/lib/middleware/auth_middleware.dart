import '../utils/import_export.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    print('AuthMiddleware: Checking route $route');
    final authController = Get.find<AuthController>();
    final userController = Get.find<UserController>();

    print('AuthMiddleware: isLoggedIn = ${authController.isLoggedIn.value}');
    print('AuthMiddleware: currentUser = ${userController.currentUser.value}');

    if (userController.currentUser.value == null || !authController.isLoggedIn.value) {
      print('AuthMiddleware: Redirecting to login');
      return const RouteSettings(name: ROUTE_LOGIN);
    }
    print('AuthMiddleware: Allowing navigation to $route');
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    return page;
  }
}
