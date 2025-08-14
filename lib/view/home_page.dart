import '../utils/import_export.dart';

class HomePage extends StatelessWidget {
  final EventController eventController = Get.find<EventController>();
  final UserController userController = Get.find<UserController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final InviteController inviteController = Get.find<InviteController>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Load both created and invited events when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventController.loadEvents();
      inviteController.loadInvitedEvents();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Get.toNamed(ROUTE_PROFILE);
                  break;
                case 'my_invites':
                  Get.toNamed(ROUTE_MY_INVITES);
                  break;
                case 'theme':
                  Get.toNamed(ROUTE_THEME_CUSTOMIZATION);
                  break;
                case 'invisible_events':
                  Get.toNamed(ROUTE_INVISIBLE_EVENTS);
                  break;
                case 'logout':
                  userController.clearCurrentUser();
                  Get.offAllNamed(ROUTE_LOGIN);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(leading: Icon(Icons.person), title: Text('Profile')),
              ),
              const PopupMenuItem(
                value: 'my_invites',
                child: ListTile(leading: Icon(Icons.inbox), title: Text('My Invites')),
              ),
              const PopupMenuItem(
                value: 'invisible_events',
                child: ListTile(leading: Icon(Icons.visibility_off), title: Text('Hidden Events')),
              ),
              const PopupMenuItem(
                value: 'theme',
                child: ListTile(leading: Icon(Icons.palette), title: Text('Customize Theme')),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search my events...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
              ),
              onChanged: (value) => eventController.searchQuery.value = value,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (eventController.isLoading.value || inviteController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final allEvents = <Map<String, dynamic>>[];
              
              // Add visible created events
              for (final event in eventController.events) {
                if (event.isVisible) {
                  allEvents.add({
                    'event': event,
                    'type': 'created',
                    'role': null,
                  });
                }
              }
              
              // Add invited events (only accepted invites)
              for (final invitedEvent in inviteController.invitedEvents) {
                final event = invitedEvent['event'] as Event;
                final invite = invitedEvent['invite'] as EventUserModel;
                
                // Only add if user is not the creator (to avoid duplicates)
                if (event.createdBy != userController.currentUser.value?.userId) {
                  allEvents.add({
                    'event': event,
                    'type': 'invited',
                    'role': invite,
                  });
                }
              }
              
              // Sort by start date
              allEvents.sort((a, b) => (b['event'] as Event).startDateTime.compareTo((a['event'] as Event).startDateTime));
              
              if (allEvents.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No events found'),
                      Text('Create an event or accept an invitation to see events here'),
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  await eventController.loadEvents();
                  await inviteController.loadInvitedEvents();
                },
                child: ListView.builder(
                  itemCount: allEvents.length,
                  itemBuilder: (context, index) {
                    final eventData = allEvents[index];
                    final event = eventData['event'] as Event;
                    final type = eventData['type'] as String;
                    final role = eventData['role'] as EventUserModel?;
                    
                    return _buildEventCard(context, event, type, role);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(ROUTE_CREATE_EVENT),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event, String type, EventUserModel? role) {
    final theme = Theme.of(context);

    final bool isOwner = event.createdBy == userController.currentUser.value?.userId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      color: theme.cardColor,
      child: InkWell(
        onTap: () => Get.toNamed(ROUTE_EVENT_DETAILS, arguments: event),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.coverImageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                child: Image.network(
                  event.coverImageUrl!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 150,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      // Role badge
                      if (role != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: role.roleColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            role.roleDisplayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isOwner)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Owner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
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
                  if (event.address != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.address!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isOwner)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => Get.toNamed(ROUTE_EVENT_EDIT, arguments: event),
                      tooltip: 'Edit Event',
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility_off, size: 20, color: Colors.grey),
                      onPressed: () => _showHideConfirmation(context, event),
                      tooltip: 'Hide Event',
                    ),
                  ],
                ),
              ),
          ],
        ),
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
              if (success) {
                Get.back(); // Close the dialog
              }
            },
            child: const Text('Hide'),
          ),
        ],
      ),
    );
  }
}
