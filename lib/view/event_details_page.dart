import '../utils/import_export.dart';

class EventDetailsPage extends StatelessWidget {
  final Rx<Event> event;

  EventDetailsPage({super.key, required Event event}) : event = event.obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventController = Get.find<EventController>();
    final inviteController = Get.find<InviteController>();

    return Obx(() => FutureBuilder<EventUserModel?>(
      future: inviteController.getUserRoleForEvent(event.value.id),
      builder: (context, snapshot) {
        final userRole = snapshot.data;
        final isOwner = event.value.createdBy == Get.find<UserController>().currentUser.value?.userId;
        final canEdit = isOwner || (userRole?.canEditEvent ?? false);
        final canInvite = isOwner || (userRole?.canInviteUsers ?? false);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Event Details'),
            actions: [
              if (canEdit)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updated = await Get.toNamed(
                      ROUTE_EVENT_EDIT,
                      arguments: event.value,
                    );
                    if (updated is Event) {
                      event.value = updated; // Reflect new updates
                    }
                  },
                ),
              if (canInvite)
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    Get.toNamed(ROUTE_INVITE_USERS, arguments: {
                      'eventId': event.value.id,
                      'eventTitle': event.value.title,
                    });
                  },
                  tooltip: 'Invite Users',
                ),
              if (canInvite)
                IconButton(
                  icon: const Icon(Icons.people),
                  onPressed: () {
                    Get.toNamed(ROUTE_EVENT_INVITES, arguments: event.value.id);
                  },
                  tooltip: 'View Invites',
                ),
              if (canEdit)
                IconButton(
                  icon: Icon(event.value.isVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => _showVisibilityConfirmation(context),
                  tooltip: event.value.isVisible ? 'Hide Event' : 'Show Event',
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role badge at the top
                if (userRole != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: userRole.roleColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      userRole.roleDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (event.value.coverImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      event.value.coverImageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 200,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(event.value.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(event.value.description, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.calendar_today,
                    'Start: ${DateFormat('MMM dd, yyyy hh:mm a').format(event.value.startDateTime)}'),
                if (event.value.endDateTime != null)
                  _buildInfoRow(Icons.calendar_today,
                      'End: ${DateFormat('MMM dd, yyyy hh:mm a').format(event.value.endDateTime!)}'),
                if (event.value.address != null)
                  _buildInfoRow(Icons.location_on, event.value.address!),
                if (event.value.maxCapacity != null)
                  _buildInfoRow(Icons.people, 'Capacity: ${event.value.maxCapacity}'),
                const SizedBox(height: 16),
                // Status/Action Row
                if (isOwner || (userRole?.canEditEvent ?? false))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final updated = await eventController.toggleEventStatus(
                            event.value.id,
                            isCancelled: !event.value.isCancelled,
                          );
                          if (updated != null) event.value = updated;
                        },
                        child: _buildStatusChip('Cancelled', event.value.isCancelled, Colors.red),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final updated = await eventController.toggleEventStatus(
                            event.value.id,
                            isCompleted: !event.value.isCompleted,
                          );
                          if (updated != null) event.value = updated;
                        },
                        child: _buildStatusChip('Completed', event.value.isCompleted, Colors.green),
                      ),
                    ],
                  ),
                if (!isOwner && !(userRole?.canEditEvent ?? false) && userRole != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Leave Event'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final confirmed = await Get.dialog<bool>(AlertDialog(
                            title: const Text('Leave Event'),
                            content: const Text('Are you sure you want to leave this event?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Leave'),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                              ),
                            ],
                          ));
                          if (confirmed == true) {
                            final success = await Get.find<InviteController>().deleteInvite(event.value.id, userRole.userId);
                            if (success) {
                              Get.snackbar('Left Event', 'You have left the event.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
                              Get.offAllNamed(ROUTE_HOME);
                            }
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ));
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showVisibilityConfirmation(BuildContext context) {
    final isCurrentlyVisible = event.value.isVisible;
    final action = isCurrentlyVisible ? 'Hide' : 'Show';
    
    Get.dialog(
      AlertDialog(
        title: Text('$action Event'),
        content: Text(
          isCurrentlyVisible
              ? 'Are you sure you want to hide "${event.value.title}"? You can access it later from the Hidden Events menu.'
              : 'Are you sure you want to make "${event.value.title}" visible?'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await Get.find<EventController>().toggleEventVisibility(
                event.value.id,
                !isCurrentlyVisible,
              );
              if (success) {
                Get.back();
                if (isCurrentlyVisible) {
                  Get.offAllNamed(ROUTE_HOME); // Go back to HomePage if hiding
                }
              }
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }
}
