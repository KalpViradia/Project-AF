import '../utils/import_export.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userController = Get.find<UserController>();
    final authController = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final RxBool isPasswordVisible = false.obs;
    final RxBool isLoading = false.obs;
    final RxBool rememberMe = true.obs;

    // Initialize Remember Me state and prefill email if available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Only initialize if field is empty to avoid resetting user input on rebuilds
      if (emailController.text.isEmpty) {
        final prefRemember = await StorageService.getRememberMe();
        rememberMe.value = prefRemember;
        if (prefRemember) {
          final creds = await StorageService.getUserCredentials();
          final savedEmail = creds['email'];
          if (savedEmail != null && savedEmail.isNotEmpty) {
            emailController.text = savedEmail;
          }
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Logo and Welcome Section
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.event_note,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue organizing your events',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Email field with validation
              ModernTextField(
                controller: emailController,
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Email is required';
                  if (!GetUtils.isEmail(value.trim())) return 'Enter a valid email address';
                  return null;
                },
              ),
              Obx(() => userController.emailError.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: Text(
                      userController.emailError.value,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  )
                : const SizedBox.shrink()
              ),
              const SizedBox(height: 20),

              // Password field with validation
              Obx(() => ModernTextField(
                controller: passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                obscureText: !isPasswordVisible.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => isPasswordVisible.value = !isPasswordVisible.value,
                ),
              )),
              Obx(() => userController.passwordError.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: Text(
                      userController.passwordError.value,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  )
                : const SizedBox.shrink()
              ),

              const SizedBox(height: 16),
              
              // Remember Me + Forgot Password row
              Obx(() => Row(
                children: [
                  Checkbox(
                    value: rememberMe.value,
                    onChanged: (value) async {
                      final v = value ?? true;
                      rememberMe.value = v;
                      await StorageService.setRememberMe(v);
                    },
                    activeColor: theme.colorScheme.primary,
                    visualDensity: VisualDensity.compact,
                  ),
                  GestureDetector(
                    onTap: () async {
                      rememberMe.value = !rememberMe.value;
                      await StorageService.setRememberMe(rememberMe.value);
                    },
                    child: Text(
                      'Remember me',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Get.toNamed(ROUTE_RESET_PASSWORD),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 32),

              // Login Button
              Obx(() => ModernButton(
                text: 'Sign In',
                icon: Icons.login,
                isLoading: isLoading.value,
                width: double.infinity,
                onPressed: isLoading.value ? null : () async {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();

                  // Clear previous errors
                  userController.emailError.value = '';
                  userController.passwordError.value = '';

                  // Validate fields
                  bool isValid = true;

                  // Email validation
                  if (email.isEmpty) {
                    userController.emailError.value = 'Email cannot be empty';
                    isValid = false;
                  } else if (!GetUtils.isEmail(email)) {
                    userController.emailError.value = 'Please enter a valid email';
                    isValid = false;
                  }

                  // Password validation
                  if (password.isEmpty) {
                    userController.passwordError.value = 'Password cannot be empty';
                    isValid = false;
                  }

                  if (isValid) {
                    isLoading.value = true;
                    try {
                      // Set remember me preference before login
                      await StorageService.setRememberMe(rememberMe.value);
                      await authController.login(email, password);
                    } catch (e) {
                      final raw = e.toString();
                      // Extract message from ApiException: [status] message
                      final match = RegExp(r'ApiException:\s*\[\d+\]\s*(.+)$', multiLine: true)
                          .firstMatch(raw);
                      String msg;
                      if (match != null) {
                        msg = match.group(1)!.trim();
                      } else {
                        msg = raw.replaceAll('Exception: ', '').trim();
                      }
                      if (msg.isEmpty || msg.toLowerCase().contains('unauthorized')) {
                        msg = 'Incorrect email or password. Please try again.';
                      }
                      ModernSnackbar.error(
                        title: 'Login Failed',
                        message: msg,
                      );
                    } finally {
                      isLoading.value = false;
                    }
                  }
                },
              )),

              const SizedBox(height: 24),

              const SizedBox(height: 16),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Get.offAllNamed(ROUTE_SIGNUP),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
