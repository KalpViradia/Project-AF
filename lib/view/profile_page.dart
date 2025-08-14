import '../utils/import_export.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (controller) {
        final user = controller.currentUser.value;

        return Scaffold(
          appBar: AppBar(title: const Text('My Profile')),
          body: user == null
              ? const Center(child: Text('No user found'))
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    user.avatarUrl ?? 'https://via.placeholder.com/150',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(user.email, style: const TextStyle(color: Colors.grey)),
                const Divider(height: 32),
                ListTile(title: const Text("Phone"), subtitle: Text(user.phone ?? '-')),
                ListTile(title: const Text("Gender"), subtitle: Text(user.gender ?? '-')),
                ListTile(
                    title: const Text("Date of Birth"),
                    subtitle: Text(user.dateOfBirth ?? '-')),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(ROUTE_EDIT_PROFILE);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
