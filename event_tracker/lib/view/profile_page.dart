import '../utils/import_export.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetX<UserController>(
      builder: (controller) {
        final user = controller.currentUser.value;

        return Scaffold(
          body: user == null
              ? EmptyState(
                  icon: Icons.person_off,
                  title: 'No User Found',
                  subtitle: 'Please log in to view your profile',
                )
              : CustomScrollView(
                  slivers: [
                    // Modern App Bar with Profile Header
                    SliverAppBar(
                      expandedHeight: 250, // give more room
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
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
                            child: Center(
                              child: SingleChildScrollView( // 🔥 prevents overflow
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 20),
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: theme.colorScheme.primary,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        user.name,
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.email,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.9),
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Profile Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Personal Information Section
                            Text(
                              'Personal Information',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),

                            ModernCard(
                              child: Column(
                                children: [
                                  _buildInfoTile(
                                    icon: Icons.phone,
                                    title: 'Phone Number',
                                    value: _formatPhone(user),
                                    iconColor: theme.colorScheme.primary,
                                  ),
                                  const Divider(height: 24),
                                  _buildInfoTile(
                                    icon: Icons.person,
                                    title: 'Gender',
                                    value: user.gender ?? 'Not specified',
                                    iconColor: theme.colorScheme.secondary,
                                  ),
                                  const Divider(height: 24),
                                  _buildInfoTile(
                                    icon: Icons.cake,
                                    title: 'Date of Birth',
                                    value: _formatDateOfBirth(user.dateOfBirth),
                                    iconColor: theme.colorScheme.tertiary,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Edit Profile Button
                            ModernButton(
                              text: 'Edit Profile',
                              icon: Icons.edit,
                              width: double.infinity,
                              onPressed: () async {
                                await Get.toNamed(ROUTE_EDIT_PROFILE);
                                // Refresh the user data when returning from edit page
                                final userController = Get.find<UserController>();
                                final authController = Get.find<AuthController>();
                                if (authController.currentUser.value != null) {
                                  userController.setCurrentUser(authController.currentUser.value!);
                                }
                              },
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  String _formatDateOfBirth(String? dateOfBirth) {
    if (dateOfBirth == null || dateOfBirth.isEmpty) {
      return 'Not provided';
    }
    
    try {
      // Parse the date string and format it to show only the date part
      final DateTime date = DateTime.parse(dateOfBirth);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      // If parsing fails, return the original string
      return dateOfBirth;
    }
  }

  String _formatPhone(UserModel user) {
    final rawNumber = (user.phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final cc = (user.countryCode ?? '').trim();
    if (rawNumber.isEmpty && cc.isEmpty) return 'Not provided';

    if (cc.isNotEmpty) {
      final normCc = cc.startsWith('+') ? cc : '+$cc';
      return rawNumber.isNotEmpty ? '$normCc $rawNumber' : normCc;
    }

    // Try to parse E.164 if phone itself contains +
    final raw = user.phone ?? '';
    if (raw.startsWith('+')) {
      final compact = raw.replaceAll(' ', '');
      final m = RegExp(r'^(\+\d{1,4})(\d+)$').firstMatch(compact);
      if (m != null) return '${m.group(1)} ${m.group(2)}';
    }

    return rawNumber.isNotEmpty ? rawNumber : 'Not provided';
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Get.theme.textTheme.bodySmall?.copyWith(
                  color: Get.theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Get.theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
