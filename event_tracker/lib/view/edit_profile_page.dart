import '../utils/import_export.dart';
import 'package:flutter/services.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final bioController = TextEditingController();

  String selectedGender = 'Prefer not to say';

  final List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    final user = Get.find<UserController>().currentUser.value;
    if (user != null) {
      nameController.text = user.name;
      phoneController.text = user.phone ?? '';
      selectedGender = user.gender ?? 'Prefer not to say';
      dobController.text = user.dateOfBirth ?? '';
      bioController.text = user.bio ?? '';
    }
  }

  void _showDatePicker(BuildContext ctx) async {
    final initialDate = DateTime.tryParse(dobController.text) ?? DateTime(2000);
    final DateTime? picked = await showDatePicker(
      context: ctx,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobController.text = picked.toIso8601String().split('T').first;
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Get.find<AuthController>();
    final oldUser = authController.currentUser.value!;

    final updatedUser = oldUser.copyWith(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      gender: selectedGender,
      dateOfBirth: dobController.text.trim(),
      bio: bioController.text.trim(),
    );

    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      await authController.updateProfile(updatedUser);
      
      // Close loading dialog first
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      // Show success feedback
      HapticFeedback.lightImpact();
      
      // Navigate back to profile page immediately
      Get.back();
      
      // Show success message after navigation
      Future.delayed(const Duration(milliseconds: 100), () {
        ModernSnackbar.success(
          title: "Profile Updated",
          message: "Your profile has been updated successfully",
        );
      });
      
    } catch (e) {
      // Close loading dialog if it's open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      ModernSnackbar.error(
        title: 'Update Failed',
        message: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Update Your Profile',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep your information up to date',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Name
              ModernTextField(
                controller: nameController,
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_rounded,
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
              const SizedBox(height: 20),

              // Phone
              ModernTextField(
                controller: phoneController,
                labelText: 'Phone Number',
                hintText: '1234567890',
                prefixIcon: Icons.phone_rounded,
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
              ),
              const SizedBox(height: 20),

              // Gender
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedGender,
                  items: genderOptions
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => selectedGender = value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // DOB
              GestureDetector(
                onTap: () => _showDatePicker(context),
                child: AbsorbPointer(
                  child: ModernTextField(
                    controller: dobController,
                    labelText: 'Date of Birth',
                    hintText: 'Select your date of birth',
                    prefixIcon: Icons.cake_rounded,
                    suffixIcon: const Icon(Icons.calendar_today_rounded),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Date of Birth is required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bio
              ModernTextField(
                controller: bioController,
                labelText: 'Bio',
                hintText: 'Tell us about yourself (optional)',
                prefixIcon: Icons.info_rounded,
                maxLines: 4,
              ),

              const SizedBox(height: 32),

              // Save Button
              ModernButton(
                text: 'Save Profile',
                icon: Icons.save_rounded,
                width: double.infinity,
                onPressed: _saveProfile,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
