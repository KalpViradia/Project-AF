import '../utils/import_export.dart';

class InviteUsersPage extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const InviteUsersPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  Widget build(BuildContext context) {
    final inviteController = Get.find<InviteController>();
    final phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => Get.toNamed(ROUTE_EVENT_INVITES, arguments: eventId),
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
                  'Invite to: $eventTitle',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Search by Phone Number',
                    hintText: 'Enter phone number to search',
                    prefixIcon: const Icon(Icons.phone),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        inviteController.searchQuery.value = phoneController.text.trim();
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    inviteController.searchQuery.value = value;
                  },
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

  Widget _buildUserCard(BuildContext context, UserModel user, InviteController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.avatarUrl != null
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null
              ? Text(user.name[0].toUpperCase())
              : null,
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text(user.phone),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            final success = await controller.createEventInvite(eventId, user.userId);
            if (success) {
              // Remove from search results after successful invite
              controller.searchResults.remove(user);
            }
          },
          child: const Text('Invite'),
        ),
      ),
    );
  }
} 