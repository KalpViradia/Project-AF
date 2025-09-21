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
      await authController.checkAuthStatus();

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
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              theme.colorScheme.tertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
              // Animated Logo
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/AppLogo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.event_note,
                              size: 80,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // App Title with Animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 2000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Column(
                        children: [
                          Text(
                            'Event Tracker',
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Organize • Connect • Celebrate',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Loading Indicator
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 2500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
                  ],
                ),
              ),
              
              // White strip with logos at the bottom
              _buildLogoStrip(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLogoStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // DU Logo (flex: 2)
          Expanded(
            flex: 2,
            child: Container(
              height: 60, // same height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/DULogo.jpg',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.school,
                        color: Colors.grey,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 24),

          // ASWDC Logo (flex: 1)
          Expanded(
            flex: 1,
            child: Container(
              height: 60, // keep same height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/ASWDCLogo.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.code,
                        color: Colors.grey,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
