import '../utils/import_export.dart';
import 'package:flutter/services.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final authController = Get.find<AuthController>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    final RxString phoneError = ''.obs;
    final RxBool isPasswordVisible = false.obs;

    // Phone number formatter to limit to 10 digits
    final phoneFormatter = FilteringTextInputFormatter.digitsOnly;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Name field with validation
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            Obx(() => userController.nameError.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    userController.nameError.value,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                )
              : const SizedBox.shrink()
            ),
            const SizedBox(height: 16),
            
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
            
            // Phone field with validation
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                phoneFormatter,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                labelText: 'Phone Number * (10 digits)',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                hintText: '1234567890',
              ),
              onChanged: (value) {
                if (value.length < 10 && value.isNotEmpty) {
                  phoneError.value = 'Phone number must be 10 digits';
                } else {
                  phoneError.value = '';
                }
              },
            ),
            Obx(() => phoneError.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    phoneError.value,
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
            const SizedBox(height: 8),
            const Text(
              'Password must be at least 6 characters long',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final phone = phoneController.text.trim();
                final password = passwordController.text.trim();

                // Clear previous errors
                userController.nameError.value = '';
                userController.emailError.value = '';
                userController.passwordError.value = '';
                phoneError.value = '';

                // Validate all fields
                bool isValid = true;

                // Name validation
                if (name.isEmpty) {
                  userController.nameError.value = 'Name cannot be empty';
                  isValid = false;
                } else if (name.length < 2) {
                  userController.nameError.value = 'Name must be at least 2 characters';
                  isValid = false;
                }

                // Email validation
                if (email.isEmpty) {
                  userController.emailError.value = 'Email cannot be empty';
                  isValid = false;
                } else if (!GetUtils.isEmail(email)) {
                  userController.emailError.value = 'Please enter a valid email';
                  isValid = false;
                }

                // Phone validation
                if (phone.isEmpty) {
                  phoneError.value = 'Phone number cannot be empty';
                  isValid = false;
                } else if (phone.length != 10) {
                  phoneError.value = 'Phone number must be exactly 10 digits';
                  isValid = false;
                }

                // Password validation
                if (password.isEmpty) {
                  userController.passwordError.value = 'Password cannot be empty';
                  isValid = false;
                } else if (password.length < 6) {
                  userController.passwordError.value = 'Password must be at least 6 characters';
                  isValid = false;
                }

                if (isValid) {
                  try {
                    final user = UserModel(
                      userId: const Uuid().v4(),
                      name: name,
                      email: email,
                      password: password,
                      phone: phone,
                      createdAt: DateTime.now().toIso8601String(),
                    );
                    
                    await authController.signUp(user);
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Failed to create account. Please try again.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () => Get.offAllNamed(ROUTE_LOGIN),
                  child: const Text('Login'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
