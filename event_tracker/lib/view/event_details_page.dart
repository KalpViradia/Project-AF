import '../utils/import_export.dart';
import '../controller/category_controller.dart';
import 'event_comments_page.dart';

class EventDetailsPage extends StatelessWidget {
  final Rx<Event> event;

  EventDetailsPage({super.key, required Event event}) : event = event.obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventController = Get.find<EventController>();
    final inviteController = Get.find<InviteController>();
    final categoryController = Get.put(CategoryController(Get.find()));

    return Obx(() => FutureBuilder<EventInviteModel?>(
      future: inviteController.getInviteDetails(event.value.id),
      builder: (context, snapshot) {
        final invite = snapshot.data;
        final isOwner = event.value.createdBy == Get.find<UserController>().currentUser.value?.userId;
        final hasPermissions = invite?.status == InviteStatus.accepted;
        final canEdit = isOwner || hasPermissions;
        final canInvite = isOwner || hasPermissions;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Modern App Bar with Hero Image
              SliverAppBar(
                expandedHeight: 250,
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
                    child: Center(
                      child: _buildEventIcon(event.value, categoryController),
                    ),
                  ),
                ),
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
                          event.value = updated;
                        }
                      },
                      tooltip: 'Edit Event',
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
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () {
                      Get.to(() => EventCommentsPage(event: event.value));
                    },
                    tooltip: 'Comments & Announcements',
                  ),
                  if (canEdit)
                    IconButton(
                      icon: Icon(
                        event.value.isVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => _showVisibilityConfirmation(context),
                      tooltip: event.value.isVisible ? 'Hide Event' : 'Show Event',
                    ),
                ],
              ),

              // Event Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge at the top
                      if (invite != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: StatusBadge(
                            text: invite.statusDisplayName,
                            color: invite.statusColor,
                          ),
                        ),

                      // Event Title and Description
                      Text(
                        event.value.title,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        event.value.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),

                      // Category chip
                      if (event.value.categoryId != null) ...[
                        const SizedBox(height: 16),
                        _buildCategoryChip(event.value, categoryController, theme),
                      ],

                      const SizedBox(height: 32),
                      // Event Details Cards
                      ModernCard(
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.schedule_rounded,
                              'Start Date & Time',
                              DateFormat('MMM dd, yyyy • hh:mm a').format(event.value.startDateTime),
                              theme.colorScheme.primary,
                            ),
                            if (event.value.endDateTime != null) ...[
                              const Divider(height: 24),
                              _buildInfoRow(
                                Icons.event_rounded,
                                'End Date & Time',
                                DateFormat('MMM dd, yyyy • hh:mm a').format(event.value.endDateTime!),
                                theme.colorScheme.secondary,
                              ),
                            ],
                            if (event.value.address != null) ...[
                              const Divider(height: 24),
                              _buildInfoRow(
                                Icons.location_on_rounded,
                                'Location',
                                event.value.address!,
                                theme.colorScheme.tertiary,
                              ),
                            ],
                            if (event.value.maxCapacity != null) ...[
                              const Divider(height: 24),
                              _buildInfoRow(
                                Icons.people_rounded,
                                'Maximum Capacity',
                                '${event.value.maxCapacity} attendees',
                                theme.colorScheme.outline,
                              ),
                              const Divider(height: 24),
                              FutureBuilder<Map<String, dynamic>>(
                                future: Get.find<EventService>().getEventCapacityInfo(event.value.id),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final data = snapshot.data!;
                                    final totalParticipants = (data['acceptedParticipants'] as int?) ?? 0;
                                    final availableSpaces = (data['availableSpaces'] as int?) ?? 0;
                                    
                                    return Column(
                                      children: [
                                        _buildInfoRow(
                                          Icons.group,
                                          'Current Participants',
                                          '$totalParticipants participants',
                                          theme.colorScheme.primary,
                                        ),
                                        const Divider(height: 24),
                                        _buildInfoRow(
                                          Icons.event_seat,
                                          'Available Spaces',
                                          '$availableSpaces spaces remaining',
                                          availableSpaces > 0 ? Colors.green : Colors.red,
                                        ),
                                      ],
                                    );
                                  }
                                  return _buildInfoRow(
                                    Icons.hourglass_empty,
                                    'Loading capacity...',
                                    'Please wait',
                                    theme.colorScheme.outline,
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                // Status/Action Row
                if (isOwner || hasPermissions)
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
                      if (!isOwner && !hasPermissions && invite != null)
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
                            final success = await Get.find<InviteController>().deleteInvite(invite.id);
                            if (success) {
                              ModernSnackbar.success(
                                title: 'Left Event',
                                message: 'You have left the event successfully',
                              );
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
              ),
            ],
          ),
        );
      },
    ));
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
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
              Get.back(); // Close dialog first
              final success = await Get.find<EventController>().toggleEventVisibility(
                event.value.id,
                !isCurrentlyVisible,
              );
              if (success) {
                // Update local event state
                event.value = event.value.copyWith(isVisible: !isCurrentlyVisible);
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

  Widget _buildEventIcon(Event event, CategoryController categoryController) {
    if (event.categoryId != null) {
      final category = categoryController.getCategoryById(event.categoryId!);
      if (category != null) {
        return Icon(
          category.iconData,
          size: 80,
          color: Colors.white.withValues(alpha: 0.8),
        );
      }
    }
    return Icon(
      Icons.event_note,
      size: 80,
      color: Colors.white.withValues(alpha: 0.8),
    );
  }

  Widget _buildCategoryChip(Event event, CategoryController categoryController, ThemeData theme) {
    final category = categoryController.getCategoryById(event.categoryId!);
    if (category == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.iconData,
              size: 16,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
