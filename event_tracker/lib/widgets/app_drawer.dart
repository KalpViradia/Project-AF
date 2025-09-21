import '../utils/import_export.dart';

class AppDrawer extends StatelessWidget {
  final UserController userController = Get.find<UserController>();

  AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Logo
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.event_note,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // App Name
                    const Text(
                      'Event Tracker',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // User Info
                    Obx(() {
                      final user = userController.currentUser.value;
                      return Text(
                        user?.name ?? 'Welcome',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                
                // Profile
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(ROUTE_PROFILE);
                  },
                ),

                // Recurring Events
                _buildDrawerItem(
                  context: context,
                  icon: Icons.repeat,
                  title: 'Recurring Events',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(ROUTE_RECURRING_EVENTS);
                  },
                ),

                // Invitees List (below Recurring Events)
                _buildDrawerItem(
                  context: context,
                  icon: Icons.people_alt,
                  title: 'Invitees',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(ROUTE_INVITEES_LIST);
                  },
                ),

                // Hidden Events
                _buildDrawerItem(
                  context: context,
                  icon: Icons.visibility_off,
                  title: 'Hidden Events',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(ROUTE_INVISIBLE_EVENTS);
                  },
                ),

                // Theme
                _buildDrawerItem(
                  context: context,
                  icon: Icons.color_lens,
                  title: 'Theme',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(ROUTE_THEME);
                  },
                ),

                const Divider(height: 32),

                // About Us (at bottom)
                _buildDrawerItem(
                  context: context,
                  icon: Icons.info,
                  title: 'About Us',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(ROUTE_ABOUT_US);
                  },
                ),

                const Divider(height: 16),

                // Logout
                _buildDrawerItem(
                  context: context,
                  icon: Icons.logout,
                  title: 'Logout',
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutConfirmation(context);
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? theme.colorScheme.onSurfaceVariant,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      horizontalTitleGap: 16,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              // Use centralized logout to clear tokens and set force-logout flag
              await Get.find<AuthController>().logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
