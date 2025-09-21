import '../utils/import_export.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final RxString phoneError = ''.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  String _dialCode = '+91';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userController = Get.find<UserController>();
    final authController = Get.find<AuthController>();


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

              // Phone with Country Code
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surface,
                    ),
                    child: Theme(
                      data: theme.copyWith(
                        dialogBackgroundColor: theme.colorScheme.surface,
                        textTheme: theme.textTheme,
                        listTileTheme: ListTileThemeData(
                          textColor: theme.colorScheme.onSurface,
                          iconColor: theme.colorScheme.onSurfaceVariant,
                          selectedColor: theme.colorScheme.primary,
                          selectedTileColor: theme.colorScheme.primary.withOpacity(0.08),
                        ),
                        dividerColor: theme.colorScheme.outline,
                      ),
                      child: CountryCodePicker(
                        onChanged: (code) {
                          setState(() {
                            _dialCode = code.dialCode ?? _dialCode;
                          });
                        },
                        initialSelection: _dialCode.startsWith('+') ? _dialCode : 'IN',
                        favorite: const ['+91', 'IN'],
                        showFlag: true,
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        textStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        dialogTextStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        closeIcon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        searchDecoration: InputDecoration(
                          hintText: 'Search country or code...',
                          prefixIcon: const Icon(Icons.search),
                          prefixIconColor: theme.colorScheme.onSurfaceVariant,
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.primary),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                        barrierColor: theme.colorScheme.scrim.withOpacity(0.32),
                        backgroundColor: theme.colorScheme.surface,
                        dialogBackgroundColor: theme.colorScheme.surface,
                        boxDecoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModernTextField(
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
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Phone number is required';
                        if (v.length != 10) return 'Phone number must be exactly 10 digits';
                        if (!RegExp(r'^\d{10}$').hasMatch(v)) return 'Digits only';
                        return null;
                      },
                      onChanged: (value) {
                        final v = value.trim();
                        if (v.isNotEmpty && v.length != 10) {
                          phoneError.value = 'Phone number must be exactly 10 digits';
                        } else {
                          phoneError.value = '';
                        }
                      },
                    ),
                  ),
                ],
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
                final phoneDigits = phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
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
                if (phoneDigits.isEmpty) {
                  phoneError.value = 'Phone number cannot be empty';
                  isValid = false;
                } else if (phoneDigits.length != 10) {
                  phoneError.value = 'Phone number must be exactly 10 digits';
                  isValid = false;
                }

                // Password validation
                if (password.isEmpty) {
                  userController.passwordError.value = 'Password cannot be empty';
                  isValid = false;
                } else if (password.length < 8) {
                  userController.passwordError.value = 'Password must be at least 8 characters';
                  isValid = false;
                } else if (!RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(password)) {
                  userController.passwordError.value =
                      'Password must contain at least one digit and one special character';
                  isValid = false;
                } else {
                  userController.passwordError.value = ''; // clear error if valid
                }

                  if (isValid) {
                    isLoading.value = true;
                    try {
                      await authController.register(
                        name,
                        email,
                        password,
                        phone: phoneDigits,
                        countryCode: _dialCode,
                      );
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
