import '../utils/import_export.dart';

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
  final avatarController = TextEditingController();
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
      avatarController.text = user.avatarUrl ?? '';
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

    final controller = Get.find<UserController>();
    final oldUser = controller.currentUser.value!;

    final updatedUser = oldUser.copyWith(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      gender: selectedGender,
      dateOfBirth: dobController.text.trim(),
      avatarUrl: avatarController.text.trim(),
      bio: bioController.text.trim(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    await controller.updateUserProfile(updatedUser);
    Get.back();
    Get.snackbar('Profile Updated', 'Your profile has been saved successfully.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),

              // Phone
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Phone is required';
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Enter a valid 10-digit number';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Gender
              DropdownButtonFormField<String>(
                value: selectedGender,
                items: genderOptions
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedGender = value);
                },
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              const SizedBox(height: 12),

              // DOB
              TextFormField(
                controller: dobController,
                readOnly: true,
                onTap: () => _showDatePicker(context),
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Date of Birth is required' : null,
              ),
              const SizedBox(height: 12),

              // Avatar URL
              TextFormField(
                controller: avatarController,
                decoration: const InputDecoration(labelText: 'Avatar URL'),
              ),
              const SizedBox(height: 12),

              // Bio
              TextFormField(
                controller: bioController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
