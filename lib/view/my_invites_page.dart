import '../utils/import_export.dart';

class MyInvitesPage extends StatelessWidget {
  const MyInvitesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inviteController = Get.find<InviteController>();

    // Load user invites when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      inviteController.loadUserInvites();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Invites'),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filter by: '),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => DropdownButton<String>(
                    value: inviteController.selectedStatus.value,
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All')),
                      const DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      const DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                      const DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        inviteController.selectedStatus.value = value;
                      }
                    },
                  )),
                ),
              ],
            ),
          ),
          
          // Invites List
          Expanded(
            child: Obx(() {
              if (inviteController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final filteredInvites = inviteController.getFilteredInvites();
              
              if (filteredInvites.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No invites found'),
                      Text('You haven\'t received any invites yet'),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: filteredInvites.length,
                itemBuilder: (context, index) {
                  final invite = filteredInvites[index];
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
    return FutureBuilder<Map<String, dynamic>>(
      future: controller.getEventWithInviteInfo(invite.eventId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!['event'] == null) {
          return const Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.event)),
              title: Text('Loading...'),
            ),
          );
        }

        final event = snapshot.data!['event'] as Event;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.event, color: Colors.white),
            ),
            title: Text(event.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy hh:mm a').format(event.startDateTime),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
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
            trailing: invite.status == 'pending' ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _updateInviteStatus(context, invite, 'accepted', controller),
                  tooltip: 'Accept',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _updateInviteStatus(context, invite, 'rejected', controller),
                  tooltip: 'Reject',
                ),
              ],
            ) : null,
            onTap: () {
              // Navigate to event details
              Get.toNamed(ROUTE_EVENT_DETAILS, arguments: event);
            },
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

  void _updateInviteStatus(BuildContext context, EventUserModel invite, String status, InviteController controller) {
    final statusText = status == 'accepted' ? 'accept' : 'reject';
    
    Get.dialog(
      AlertDialog(
        title: Text('$statusText Invite'),
        content: Text('Are you sure you want to $statusText this invite?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await controller.updateInviteStatus(
                invite.eventId,
                invite.userId,
                status,
              );
              if (success) {
                Get.back(); // Close dialog
                // Refresh home page events if accepted
                if (status == 'accepted') {
                  await Get.find<InviteController>().loadInvitedEvents();
                  Get.snackbar(
                    'Success',
                    'Event added to your home page',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: Text(statusText),
            style: TextButton.styleFrom(
              foregroundColor: status == 'accepted' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
} 