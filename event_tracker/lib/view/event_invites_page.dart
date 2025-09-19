import '../utils/import_export.dart';

class EventInvitesPage extends StatelessWidget {
  final String eventId;

  const EventInvitesPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final inviteController = Get.find<InviteController>();
    final eventController = Get.find<EventController>();

    // Load event details and accepted invites when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      inviteController.loadAcceptedEventInvites(eventId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              // Get event title for the invite page
              final event = eventController.events.firstWhereOrNull(
                (e) => e.id == eventId,
              );
              if (event != null) {
                Get.toNamed(
                  ROUTE_INVITE_USERS,
                  arguments: {'eventId': eventId, 'eventTitle': event.title},
                );
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
                        'Event Members',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
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

              if (inviteController.acceptedEventInvites.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No members yet'),
                      Text('Tap the + button to invite users'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: inviteController.acceptedEventInvites.length,
                itemBuilder: (context, index) {
                  final invite = inviteController.acceptedEventInvites[index];
                  return _buildMemberCard(context, invite, inviteController);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    EventInviteModel invite,
    InviteController controller,
  ) {
    if (invite.invitedUser == null) {
      return const Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text('Loading...'),
        ),
      );
    }

    final user = invite.invitedUser!;
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            user.name[0].toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    user.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${invite.participantCount} participant${invite.participantCount > 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (user.phone != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user.phone!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Member',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.check_circle_rounded,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

}
