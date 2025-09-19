import '../utils/import_export.dart';
import '../controller/category_controller.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  final EventController eventController = Get.find<EventController>();
  final UserController userController = Get.find<UserController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final InviteController inviteController = Get.find<InviteController>();
  final CategoryController categoryController = Get.put(CategoryController(Get.find()));
  final Rxn<int> selectedCategoryFilter = Rxn<int>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Load events and invites when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventController.loadEvents();
      inviteController.loadInvitedEvents();
      inviteController.loadUserInvites();
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.event_note,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('My Events'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showCategoryFilterDialog(context, theme),
            tooltip: 'Filter by Category',
          ),
          Obx(() {
            final count = inviteController.pendingInvites.length;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: count > 0 ? theme.colorScheme.primary : null,
                  ),
                  onPressed: () async {
                    await Get.toNamed(ROUTE_MY_INVITES);
                    await inviteController.loadUserInvites();
                  },
                  tooltip: count > 0 ? 'My Invites ($count pending)' : 'My Invites',
                ),
                if (count > 0)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // Modern Search Bar
          ModernSearchBar(
            hintText: 'Search your events...',
            onChanged: (value) => eventController.searchQuery.value = value,
          ),
          Expanded(
            child: Obx(() {
              if (eventController.isLoading.value || inviteController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final allEvents = <Map<String, dynamic>>[];
              
              // Add visible created events (exclude recurring from home)
              for (final event in eventController.events) {
                if (event.isVisible && !event.isRecurring) {
                  allEvents.add({
                    'event': event,
                    'type': 'created',
                    'role': null,
                  });
                }
              }
              
              // Add invited events (only accepted invites) and exclude recurring
              for (final invitedEvent in inviteController.invitedEvents) {
                final event = invitedEvent['event'] as Event;
                final invite = invitedEvent['invite'] as EventInviteModel;
                
                // Only add if user is not the creator (to avoid duplicates)
                if (event.createdBy != userController.currentUser.value?.userId && !event.isRecurring) {
                  allEvents.add({
                    'event': event,
                    'type': 'invited',
                    'invite': invite,
                  });
                }
              }
              
              // Sort by start date
              allEvents.sort((a, b) => (b['event'] as Event).startDateTime.compareTo((a['event'] as Event).startDateTime));
              
              if (allEvents.isEmpty) {
                return EmptyState(
                  icon: Icons.event_note,
                  title: 'No events found',
                  subtitle: 'Create an event or accept an invitation to see events here',
                  actionText: 'Create Event',
                  onAction: () => Get.toNamed(ROUTE_CREATE_EVENT),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  await eventController.loadEvents();
                  await inviteController.loadInvitedEvents();
                  await inviteController.loadUserInvites();
                },
                child: Obx(() {
                  final filteredEvents = _getFilteredEvents(allEvents);
                  if (filteredEvents.isEmpty) {
                    // Keep child scrollable for RefreshIndicator compatibility
                    return ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: EmptyState(
                            icon: Icons.inbox,
                            title: 'No events found',
                            subtitle: selectedCategoryFilter.value == null
                                ? 'No events to display'
                                : 'No events found for the selected category',
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final eventData = filteredEvents[index];
                      return _buildEventCard(
                        context,
                        eventData['event'] as Event,
                        eventData['type'] as String,
                        eventData['invite'] as EventInviteModel?,
                      );
                    },
                  );
                }),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(ROUTE_CREATE_EVENT),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Create Event',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event, String type, EventInviteModel? invite) {
    final theme = Theme.of(context);
    final bool isOwner = event.createdBy == userController.currentUser.value?.userId;

    return ModernCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      onTap: () => Get.toNamed(ROUTE_EVENT_DETAILS, arguments: event),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and status badges
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              // Status badges
              Row(
                children: [
                  // Recurring event indicator
                  if (event.isRecurring)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.repeat,
                            size: 14,
                            color: theme.colorScheme.tertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.recurrenceType?.toLowerCase() ?? 'recurring',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Invite status badge
                  if (invite != null && type == 'invited')
                    StatusBadge(
                      text: 'Invited',
                      color: invite.statusColor,
                    ),
                  if (isOwner)
                    StatusBadge(
                      text: 'Owner',
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Description
          Text(
            event.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Category chip with enhanced styling
          if (event.categoryId != null) ...[
            _buildEnhancedCategoryChip(event, theme),
            const SizedBox(height: 20),
          ],

          // Event details in a modern card-like container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Date and time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.schedule_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date & Time',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MMM dd, yyyy • hh:mm a').format(event.startDateTime),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Location (if available)
                if (event.address != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 20,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event.address!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                // Capacity information (if available)
                if (event.maxCapacity != null) ...[
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, dynamic>>(
                    future: Get.find<EventService>().getEventCapacityInfo(event.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.data!;
                        final totalParticipants = (data['acceptedParticipants'] as int?) ?? 0;
                        final availableSpaces = (data['availableSpaces'] as int?) ?? 0;
                        final maxCapacity = (data['maxCapacity'] as int?) ?? 0;
                        
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (availableSpaces > 0 ? theme.colorScheme.tertiary : Colors.red).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.group_rounded,
                                size: 20,
                                color: availableSpaces > 0 ? theme.colorScheme.tertiary : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Participants',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$totalParticipants/$maxCapacity • $availableSpaces spaces left',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: availableSpaces > 0 
                                          ? theme.colorScheme.onSurface 
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        // Fallback: Show basic capacity info from event data
                        final maxCapacity = event.maxCapacity ?? 0;
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.group_rounded,
                                size: 20,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Participants',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    maxCapacity > 0 ? 'Max capacity: $maxCapacity' : 'Unlimited capacity',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.group_rounded,
                              size: 20,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Participants',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Loading...',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),
          
          // Action buttons for owner
          if (isOwner)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton.outlined(
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () => Get.toNamed(ROUTE_EVENT_EDIT, arguments: event),
                  tooltip: 'Edit Event',
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  icon: Icon(
                    Icons.visibility_off_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => _showHideConfirmation(context, event),
                  tooltip: 'Hide Event',
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showHideConfirmation(BuildContext context, Event event) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hide Event'),
        content: Text('Are you sure you want to hide "${event.title}"? You can access it later from the Hidden Events menu.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await eventController.toggleEventVisibility(event.id, false);
              if (success) Get.back(closeOverlays: true); // Close the dialog
            },
            child: const Text('Hide'),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCategoryChip(Event event, ThemeData theme) {
    final category = categoryController.getCategoryById(event.categoryId!);
    if (category == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  List<Map<String, dynamic>> _getFilteredEvents(List<Map<String, dynamic>> allEvents) {
    if (selectedCategoryFilter.value == null) {
      return allEvents;
    }
    
    return allEvents.where((eventData) {
      final event = eventData['event'] as Event;
      return event.categoryId == selectedCategoryFilter.value;
    }).toList();
  }

  void _showCategoryFilterDialog(BuildContext context, ThemeData theme) {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter by Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (categoryController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final categories = categoryController.activeCategories;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // All Categories option
                ListTile(
                  leading: const Icon(Icons.all_inclusive),
                  title: const Text('All Categories'),
                  trailing: selectedCategoryFilter.value == null 
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () {
                    selectedCategoryFilter.value = null;
                    Get.back();
                  },
                ),
                const Divider(),
                // Individual categories
                ...categories.map((category) => ListTile(
                  leading: Icon(category.iconData),
                  title: Text(category.name),
                  trailing: selectedCategoryFilter.value == category.categoryId
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () {
                    selectedCategoryFilter.value = category.categoryId;
                    Get.back();
                  },
                )),
              ],
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
