import '../utils/import_export.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final authController = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final RxBool isPasswordVisible = false.obs;
    final RxBool isLoading = false.obs;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text('Welcome Back', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Email field with validation
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email *',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            Obx(() => userController.emailError.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    userController.emailError.value,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                )
              : const SizedBox.shrink()
            ),
            const SizedBox(height: 16),
            
            // Password field with validation  
            Obx(() => TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible.value,
              decoration: InputDecoration(
                labelText: 'Password *',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => isPasswordVisible.value = !isPasswordVisible.value,
                ),
              ),
            )),
            Obx(() => userController.passwordError.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    userController.passwordError.value,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                )
              : const SizedBox.shrink()
            ),
            
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Get.snackbar(
                    'Info',
                    'Contact support to reset your password',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue,
                    colorText: Colors.white,
                  );
                }, 
                child: const Text('Forgot Password?')
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => ElevatedButton(
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
                    await authController.login(email, password);
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Login failed. Please try again.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  } finally {
                    isLoading.value = false;
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading.value 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Login'),
            )),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () => Get.offAllNamed(ROUTE_SIGNUP),
                  child: const Text('Sign up'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
