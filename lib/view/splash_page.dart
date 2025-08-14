import '../utils/import_export.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthService authService = AuthService();
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // Add minimum splash screen duration
      await Future.delayed(const Duration(seconds: 2));

      final authController = Get.find<AuthController>();
      await authController.autoLogin();

      if (authController.isLoggedIn.value) {
        Get.offAllNamed(ROUTE_HOME);
      } else {
        Get.offAllNamed(ROUTE_LOGIN);
      }
    } catch (e) {
      print('Error during app initialization: $e');
      await Future.delayed(const Duration(seconds: 1)); // Show error state briefly
      Get.offAllNamed(ROUTE_LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor.withOpacity(0.6),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Event Tracker',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
