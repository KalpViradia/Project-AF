import '../utils/import_export.dart';

class MyInvitesPage extends StatelessWidget {
  const MyInvitesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inviteController = Get.find<InviteController>();

    // Load user invites when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      inviteController.loadUserInvites();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Invites'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Modern Filter Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Filter by status:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: DropdownButton<String>(
                      value: inviteController.selectedStatus.value,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem(value: 'all', child: Text('All Invites')),
                        const DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        const DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                        // Use 'declined' value to match InviteStatus and parser
                        const DropdownMenuItem(value: 'declined', child: Text('Rejected')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          inviteController.selectedStatus.value = value;
                        }
                      },
                    ),
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
                return EmptyState(
                  icon: Icons.inbox,
                  title: 'No invites found',
                  subtitle: 'You haven\'t received any invites yet',
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

  Widget _buildInviteCard(BuildContext context, EventInviteModel invite, InviteController controller) {
    if (invite.event == null) {
      return ModernCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.event_note,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text('Loading event details...'),
            ),
          ],
        ),
      );
    }

    final event = invite.event!;
    final theme = Theme.of(context);
    
    return ModernCard(
        onTap: () => Get.toNamed(ROUTE_EVENT_DETAILS, arguments: event),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with event title and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                StatusBadge(
                  text: invite.statusDisplayName,
                  color: invite.statusColor,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Event description
            Text(
              event.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Event details
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(
                        event.startDateTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Role information and participant count
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  text: event.createdBy == invite.invitedUserId
                      ? 'Owner'
                      : 'Invitee',
                  color: event.createdBy == invite.invitedUserId
                      ? Colors.red
                      : Colors.grey,
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.group,
                  size: 16,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${invite.participantCount} participant${invite.participantCount > 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Action buttons for pending invites
            if (invite.status == InviteStatus.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ModernButton(
                      text: 'Accept',
                      icon: Icons.check,
                      onPressed: () =>
                          _handleInviteResponse(
                              invite, InviteStatus.accepted, controller),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ModernButton(
                      text: 'Decline',
                      icon: Icons.close,
                      isSecondary: true,
                      onPressed: () =>
                          _handleInviteResponse(
                              invite, InviteStatus.declined, controller),
                    ),
                  ),
                ],
              ),
            ],

            // Edit participant count for accepted invites
            if (invite.status == InviteStatus.accepted) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ModernButton(
                      text: 'Edit Participants',
                      icon: Icons.edit,
                      isSecondary: true,
                      onPressed: () => _showEditParticipantsDialog(context, invite, controller),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
  }

  

  void _handleInviteResponse(EventInviteModel invite, InviteStatus status, InviteController controller) {
    final statusText = status == InviteStatus.accepted ? 'accept' : 'decline';

    Get.dialog(
      AlertDialog(
        title: Text('${statusText[0].toUpperCase()}${statusText.substring(1)} Invite'),
        content: Text('Are you sure you want to $statusText this invitation?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: status == InviteStatus.accepted ? Colors.green : Colors.red,
            ),
            onPressed: () async {
              Get.back(); // Close dialog first

              if (status == InviteStatus.accepted) {
                // Show participant count selection dialog for accepting
                _showParticipantSelectionDialog(Get.context!, invite, controller);
              } else {
                final success = await controller.updateInviteStatus(invite.id, status);
                if (success) {
                  ModernSnackbar.warning(
                    title: 'Invite Declined',
                    message: 'You have declined this invitation',
                  );
                } else {
                  ModernSnackbar.error(
                    title: 'Update Failed',
                    message: 'Failed to update invite status. Please try again.',
                  );
                }
              }
            },
            child: Text('${statusText[0].toUpperCase()}${statusText.substring(1)}'),
          ),
        ],
      ),
    );
  }

  void _showParticipantSelectionDialog(BuildContext context, EventInviteModel invite, InviteController controller) {
    final RxInt participantCount = 1.obs;
    final theme = Theme.of(context);
    final event = invite.event!;

    Get.dialog(
      AlertDialog(
        title: const Text('Select Participants'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How many participants will attend "${event.title}"?',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, dynamic>>(
                future: Get.find<EventService>().getEventCapacityInfo(event.id),
                builder: (context, snapshot) {
                  final availableSpaces = snapshot.hasData 
                      ? ((snapshot.data!['availableSpaces'] as int?) ?? 0)
                      : (event.maxCapacity ?? 100);
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available spaces: $availableSpaces',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: availableSpaces > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() => IconButton(
                            onPressed: participantCount.value > 1 
                                ? () => participantCount.value--
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: 'Decrease participants',
                          )),
                          Obx(() => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${participantCount.value}',
                              style: theme.textTheme.titleLarge,
                            ),
                          )),
                          Obx(() => IconButton(
                            onPressed: participantCount.value < availableSpaces
                                ? () => participantCount.value++
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: participantCount.value < availableSpaces
                                ? 'Increase participants'
                                : 'Event capacity reached',
                          )),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            onPressed: () async {
              Get.back();
              
              final success = await controller.updateInviteStatusWithParticipants(
                invite.id, 
                InviteStatus.accepted,
                participantCount.value,
              );
              
              if (success) {
                await Get.find<InviteController>().loadInvitedEvents();
                ModernSnackbar.success(
                  title: 'Invite Accepted',
                  message: 'Event has been added to your home page with ${participantCount.value} participant${participantCount.value > 1 ? 's' : ''}',
                );
              } else {
                ModernSnackbar.error(
                  title: 'Update Failed',
                  message: 'Failed to accept invite. Please try again.',
                );
              }
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showEditParticipantsDialog(BuildContext context, EventInviteModel invite, InviteController controller) {
    final RxInt participantCount = invite.participantCount.obs;
    final theme = Theme.of(context);
    final event = invite.event!;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Participant Count'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event: ${event.title}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (event.maxCapacity != null) ...[
                Text(
                  'Event Capacity: ${event.maxCapacity}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Number of Participants:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<Map<String, dynamic>>(
                future: Get.find<EventService>().getEventCapacityInfo(event.id),
                builder: (context, snapshot) {
                  final availableSpaces = snapshot.hasData 
                      ? ((snapshot.data!['availableSpaces'] as int?) ?? 0)
                      : (event.maxCapacity ?? 100);
                  
                  // Calculate max for this user: current participant count + available spaces
                  final maxForThisUser = invite.participantCount + availableSpaces;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (snapshot.hasData) ...[
                        Text(
                          'Available spaces: $availableSpaces',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: availableSpaces > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: participantCount.value > 1 
                                ? () => participantCount.value-- 
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: 'Decrease participants',
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${participantCount.value}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: participantCount.value < maxForThisUser
                                ? () => participantCount.value++
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: participantCount.value < maxForThisUser
                                ? 'Increase participants'
                                : 'Event capacity reached',
                          ),
                        ],
                      )),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                        participantCount.value >= maxForThisUser 
                            ? 'Maximum capacity reached'
                            : 'You can add up to ${maxForThisUser - participantCount.value} more participants',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: participantCount.value >= maxForThisUser 
                              ? Colors.red 
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      )),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog first
              
              final success = await controller.updateInviteStatusWithParticipants(
                invite.id, 
                InviteStatus.accepted, 
                participantCount.value,
              );
              
              if (success) {
                ModernSnackbar.success(
                  title: 'Participants Updated',
                  message: 'Updated to ${participantCount.value} participant${participantCount.value > 1 ? 's' : ''}',
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
} 