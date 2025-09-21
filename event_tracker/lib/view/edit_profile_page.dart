import '../utils/import_export.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';

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
  String _dialCode = '+91';

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
      // Prefer stored countryCode; otherwise parse from existing E.164 phone
      final savedCc = user.countryCode;
      final rawPhone = user.phone ?? '';
      if (savedCc != null && savedCc.trim().isNotEmpty) {
        _dialCode = savedCc.startsWith('+') ? savedCc : '+$savedCc';
        // Keep only national number (digits only) in the text field
        phoneController.text = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
      } else if (rawPhone.startsWith('+')) {
        final compact = rawPhone.replaceAll(' ', '');
        final match = RegExp(r'^(\+\d{1,4})(\d+)$').firstMatch(compact);
        if (match != null) {
          _dialCode = match.group(1)!;
          phoneController.text = match.group(2)!; // digits only
        } else {
          // fallback: strip non-digits and keep default code
          phoneController.text = compact.replaceAll(RegExp(r'[^0-9]'), '');
        }
      } else {
        // No plus in stored phone; assume it's already national number digits
        phoneController.text = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
      }
      selectedGender = user.gender ?? 'Prefer not to say';

      if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
        try {
          final DateTime date = DateTime.parse(user.dateOfBirth!);
          dobController.text = date.toIso8601String().split('T').first;
        } catch (e) {
          dobController.text = user.dateOfBirth!;
        }
      } else {
        // Default to 18 years before today
        final now = DateTime.now();
        final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
        dobController.text = eighteenYearsAgo.toIso8601String().split('T').first;
      }

      bioController.text = user.bio ?? '';
    }
  }

  void _showDatePicker(BuildContext ctx) async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

    DateTime initialDate;
    if (dobController.text.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(dobController.text);
        initialDate = parsedDate.isAfter(eighteenYearsAgo) ? eighteenYearsAgo : parsedDate;
      } catch (e) {
        initialDate = eighteenYearsAgo;
      }
    } else {
      // Default initial date is 18 years before today
      initialDate = eighteenYearsAgo;
    }

    final DateTime? picked = await showDatePicker(
      context: ctx,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: eighteenYearsAgo,
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
      // Store only national number (digits) in phone, country code separately
      phone: phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), ''),
      countryCode: _dialCode,
      gender: selectedGender,
      dateOfBirth: dobController.text.trim(),
      bio: bioController.text.trim(),
    );

    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      await authController.updateProfile(updatedUser);

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      HapticFeedback.lightImpact();

      Get.back();

      Future.delayed(const Duration(milliseconds: 100), () {
        ModernSnackbar.success(
          title: "Profile Updated",
          message: "Your profile has been updated successfully",
        );
      });
    } catch (e) {
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone Number',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                          prefixIcon: Icons.phone_rounded,
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

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

              GestureDetector(
                onTap: () => _showDatePicker(context),
                child: AbsorbPointer(
                  child: ModernTextField(
                    controller: dobController,
                    labelText: 'Date of Birth',
                    hintText: 'Select your date of birth (must be 18+)',
                    prefixIcon: Icons.cake_rounded,
                    suffixIcon: const Icon(Icons.calendar_today_rounded),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Date of Birth is required';
                      }

                      try {
                        final selectedDate = DateTime.parse(value);
                        final now = DateTime.now();
                        final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

                        if (selectedDate.isAfter(eighteenYearsAgo)) {
                          return 'You must be at least 18 years old';
                        }

                        return null;
                      } catch (e) {
                        return 'Invalid date format';
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ModernTextField(
                controller: bioController,
                labelText: 'Bio',
                hintText: 'Tell us about yourself (optional)',
                prefixIcon: Icons.info_rounded,
                maxLines: 4,
              ),

              const SizedBox(height: 32),

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
