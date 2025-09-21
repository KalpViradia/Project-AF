import '../utils/import_export.dart';
import '../service/contact_picker_service.dart';

class InviteUsersPage extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const InviteUsersPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<InviteUsersPage> createState() => _InviteUsersPageState();
}

class _InviteUsersPageState extends State<InviteUsersPage> {
  final InviteController inviteController = Get.find<InviteController>();
  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void _applySearch(String raw) {
    final v = raw.trim();
    inviteController.searchQuery.value = v;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => Get.toNamed(ROUTE_EVENT_INVITES, arguments: widget.eventId),
            tooltip: 'View Invited Users',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite to: ${widget.eventTitle}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Search by Phone Number',
                          hintText: 'Enter phone number to search',
                          prefixIcon: const Icon(Icons.phone),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _applySearch(phoneController.text.trim()),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) => _applySearch(value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _pickContact(context, phoneController, inviteController),
                      icon: const Icon(Icons.contacts),
                      label: const Text('Contacts'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Search Results
          Expanded(
            child: Obx(() {
              if (inviteController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (inviteController.searchResults.isEmpty && inviteController.searchQuery.value.isNotEmpty) {
                return const Center(
                  child: Text('No users found with this phone number'),
                );
              }
              
              if (inviteController.searchQuery.value.isEmpty) {
                return const Center(
                  child: Text('Search for users by phone number to invite them'),
                );
              }
              
              return ListView.builder(
                itemCount: inviteController.searchResults.length,
                itemBuilder: (context, index) {
                  final user = inviteController.searchResults[index];
                  return _buildUserCard(context, user, inviteController);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _pickContact(BuildContext context, TextEditingController phoneController, InviteController inviteController) async {
    try {
      final contact = await ContactPickerService.pickContact();
      if (contact != null) {
        final phoneNumber = ContactPickerService.getFirstPhoneNumber(contact);
        if (phoneNumber != null) {
          // Use raw contact number; controller will handle candidates (digits-only, last-10, etc.)
          phoneController.text = phoneNumber;
          inviteController.searchQuery.value = phoneNumber.trim();
          
          // Show contact info in a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected: ${ContactPickerService.getDisplayName(contact)} - $phoneNumber'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected contact has no phone number'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking contact: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildUserCard(BuildContext context, UserModel user, InviteController controller) {
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        user.phone.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Container()),
                ElevatedButton.icon(
                  onPressed: () async {
                    final success = await controller.createEventInvite(
                      widget.eventId, 
                      user.userId,
                    );
                    if (success) {
                      // Remove from search results after successful invite
                      controller.searchResults.remove(user);
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Send Invite'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 