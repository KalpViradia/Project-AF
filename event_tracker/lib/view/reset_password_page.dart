import '../utils/import_export.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final RxBool isPasswordVisible = false.obs;
    final RxBool isConfirmPasswordVisible = false.obs;
    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                
                // Header
                Text(
                  'Reset Your Password',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enter your email address and create a new password.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Email Field
                ModernTextField(
                  controller: emailController,
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // New Password Field
                Obx(() => ModernTextField(
                  controller: passwordController,
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                  prefixIcon: Icons.lock,
                  obscureText: !isPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => isPasswordVisible.toggle(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                )),
                
                const SizedBox(height: 24),
                
                // Confirm Password Field
                Obx(() => ModernTextField(
                  controller: confirmPasswordController,
                  labelText: 'Confirm Password',
                  hintText: 'Confirm new password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !isConfirmPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => isConfirmPasswordVisible.toggle(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                )),
                
                const SizedBox(height: 32),
                
                // Reset Password Button
                Obx(() => ModernButton(
                  text: 'Reset Password',
                  icon: Icons.check,
                  isLoading: authController.isLoading.value,
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // Simplified forgot password flow with email and new password
                      final success = await authController.resetPasswordDirect(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                      if (success) {
                        Get.offAllNamed(ROUTE_LOGIN);
                      }
                    }
                  },
                )),
                
                const SizedBox(height: 24),
                
                // Back to Login
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Security Tips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Password Tips',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Use at least 8 characters\n• Include uppercase and lowercase letters\n• Add numbers and special characters',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
