import '../utils/import_export.dart';
import 'package:flutter/services.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userController = Get.find<UserController>();
    final authController = Get.find<AuthController>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    final RxString phoneError = ''.obs;
    final RxBool isPasswordVisible = false.obs;
    final RxBool isLoading = false.obs;


    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Header Section
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
                        Icons.person_add,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Create Account',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join us to start organizing amazing events',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Name field with validation
              ModernTextField(
                controller: nameController,
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Name is required';
                  if (value.trim().length < 2) return 'Name must be at least 2 characters';
                  if (value.trim().length > 50) return 'Name cannot exceed 50 characters';
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) return 'Name can only contain letters and spaces';
                  return null;
                },
              ),
              Obx(() => userController.nameError.value.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: Text(
                      userController.nameError.value,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  )
                : const SizedBox.shrink()
              ),
              const SizedBox(height: 20),

              // Email field with validation
              ModernTextField(
                controller: emailController,
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
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

              // Phone field with validation
              ModernTextField(
                controller: phoneController,
                labelText: 'Phone Number',
                hintText: '1234567890',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Phone number is required';
                  if (value.length != 10) return 'Phone number must be exactly 10 digits';
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) return 'Enter a valid Indian mobile number';
                  return null;
                },
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
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: Text(
                      phoneError.value,
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
              const SizedBox(height: 8),
              Text(
                'Password must be at least 8 characters with uppercase, lowercase, and number',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Sign up button
              Obx(() => ModernButton(
                text: 'Create Account',
                icon: Icons.person_add,
                isLoading: isLoading.value,
                width: double.infinity,
                onPressed: isLoading.value ? null : () async {
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
                //   } else if (password.length < 8) {
                //   userController.passwordError.value = 'Password must be at least 8 characters';
                //   isValid = false;
                // } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
                //   userController.passwordError.value = 'Password must contain uppercase, lowercase, and number';
                  isValid = false;
                }

                  if (isValid) {
                    isLoading.value = true;
                    try {
                      await authController.register(name, email, password);
                    } catch (e) {
                      ModernSnackbar.error(
                        title: 'Signup Failed',
                        message: 'Failed to create account. Please try again.',
                      );
                    } finally {
                      isLoading.value = false;
                    }
                  }
                },
              )),

              const SizedBox(height: 32),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Get.offAllNamed(ROUTE_LOGIN),
                    child: Text(
                      'Sign In',
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
