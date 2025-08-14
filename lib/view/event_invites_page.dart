import '../utils/import_export.dart';

class EventInvitesPage extends StatelessWidget {
  final String eventId;

  const EventInvitesPage({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    final inviteController = Get.find<InviteController>();
    final eventController = Get.find<EventController>();

    // Load event details and invites when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      inviteController.loadEventInvites(eventId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Invites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              // Get event title for the invite page
              final event = eventController.events.firstWhereOrNull((e) => e.id == eventId);
              if (event != null) {
                Get.toNamed(ROUTE_INVITE_USERS, arguments: {
                  'eventId': eventId,
                  'eventTitle': event.title,
                });
              }
            },
            tooltip: 'Invite More Users',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with event info
          Container(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<Event?>(
              future: eventController.getEventById(eventId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final event = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Invited Users',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  );
                }
                return const Text('Loading event details...');
              },
            ),
          ),
          
          // Invites List
          Expanded(
            child: Obx(() {
              if (inviteController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (inviteController.eventInvites.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No invites yet'),
                      Text('Tap the + button to invite users'),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: inviteController.eventInvites.length,
                itemBuilder: (context, index) {
                  final invite = inviteController.eventInvites[index];
                  return _buildInviteCard(context, invite, inviteController);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(BuildContext context, EventUserModel invite, InviteController controller) {
    return FutureBuilder<UserModel?>(
      future: _getUserById(invite.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text('Loading...'),
            ),
          );
        }

        final user = snapshot.data!;
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatusChip(invite.status),
                    const SizedBox(width: 8),
                    _buildRoleChip(invite),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    _showDeleteConfirmation(context, invite, controller);
                    break;
                  case 'resend':
                    // Resend invite logic (for now, just show a message)
                    Get.snackbar(
                      'Info',
                      'Invite already sent',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'resend',
                  child: ListTile(
                    leading: Icon(Icons.send),
                    title: Text('Resend Invite'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Remove Invite', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'accepted':
        color = Colors.green;
        label = 'Accepted';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  Widget _buildRoleChip(EventUserModel invite) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: invite.roleColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        invite.roleDisplayName,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  Future<UserModel?> _getUserById(String userId) async {
    final db = await AppDatabase().database;
    final result = await db.query(
      TBL_USERS,
      where: '$COL_USER_ID = ?',
      whereArgs: [userId],
    );
    
    return result.isNotEmpty ? UserModel.fromMap(result.first) : null;
  }

  void _showDeleteConfirmation(BuildContext context, EventUserModel invite, InviteController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Invite'),
        content: const Text('Are you sure you want to remove this invite?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await controller.deleteInvite(eventId, invite.userId);
              if (success) {
                Get.back(); // Close dialog
              }
            },
            child: const Text('Remove'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
} 