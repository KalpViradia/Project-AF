import '../utils/import_export.dart';
import '../controller/category_controller.dart';

class RecurringEventsPage extends StatelessWidget {
  final EventController eventController = Get.find<EventController>();
  final UserController userController = Get.find<UserController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final CategoryController categoryController = Get.put(CategoryController(Get.find()));

  RecurringEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Load events when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventController.loadEvents();
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.repeat,
                color: theme.colorScheme.tertiary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Recurring Events'),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Modern Search Bar
          ModernSearchBar(
            hintText: 'Search recurring events...',
            onChanged: (value) => eventController.searchQuery.value = value,
          ),
          Expanded(
            child: Obx(() {
              if (eventController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              // Filter only recurring events
              final recurringEvents = eventController.events
                  .where((event) => event.isRecurring && event.isVisible)
                  .toList();
              
              // Apply search filter
              final filteredEvents = recurringEvents.where((event) {
                final query = eventController.searchQuery.value.toLowerCase();
                return query.isEmpty ||
                    event.title.toLowerCase().contains(query) ||
                    event.description.toLowerCase().contains(query);
              }).toList();
              
              // Sort by start date
              filteredEvents.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
              
              if (filteredEvents.isEmpty) {
                return EmptyState(
                  icon: Icons.repeat,
                  title: recurringEvents.isEmpty ? 'No recurring events found' : 'No matching events',
                  subtitle: recurringEvents.isEmpty 
                      ? 'Create events like birthdays, anniversaries, or weekly meetings that repeat automatically'
                      : 'Try adjusting your search terms',
                  actionText: 'Create Recurring Event',
                  onAction: () => Get.toNamed(ROUTE_CREATE_RECURRING_EVENT),
                );
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  await eventController.loadEvents();
                },
                child: ListView.builder(
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    return _buildRecurringEventCard(context, event, theme);
                  },
                ),
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
              theme.colorScheme.tertiary,
              theme.colorScheme.tertiary.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(ROUTE_CREATE_RECURRING_EVENT),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.repeat, color: Colors.white),
          label: const Text(
            'Create Recurring',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecurringEventCard(BuildContext context, Event event, ThemeData theme) {
    final bool isOwner = event.createdBy == userController.currentUser.value?.userId;

    return ModernCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      onTap: () => Get.toNamed(ROUTE_EVENT_DETAILS, arguments: event),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and recurring badge
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
              // Recurring badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 16,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.recurrenceType?.toLowerCase() ?? 'recurring',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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

          // Category chip
          if (event.categoryId != null) ...[
            _buildCategoryChip(event, theme),
            const SizedBox(height: 20),
          ],

          // Recurring details in a card
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
                // Start date and recurrence info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.schedule,
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
                            'Recurrence Pattern',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getRecurrenceDescription(event),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Next occurrence
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.event,
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
                            'Next Occurrence',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            event.endDateTime != null
                                ? DateFormat('MMM dd, yyyy • hh:mm a').format(event.startDateTime)
                                : DateFormat('MMM dd, yyyy').format(event.startDateTime),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // End date if available
                if (event.recurrenceEndDate != null) ...[
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
                          Icons.event_busy,
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
                              'Ends On',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMM dd, yyyy').format(event.recurrenceEndDate!),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    Icons.edit,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () => Get.toNamed(ROUTE_EDIT_RECURRING_EVENT, arguments: event),
                  tooltip: 'Edit Recurring Event',
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  icon: Icon(
                    Icons.visibility_off,
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

  Widget _buildCategoryChip(Event event, ThemeData theme) {
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

  String _getRecurrenceDescription(Event event) {
    final type = event.recurrenceType?.toLowerCase() ?? 'unknown';
    final interval = event.recurrenceInterval;
    
    switch (type) {
      case 'daily':
        return interval == 1 ? 'Every day' : 'Every $interval days';
      case 'weekly':
        return interval == 1 ? 'Every week' : 'Every $interval weeks';
      case 'monthly':
        return interval == 1 ? 'Every month' : 'Every $interval months';
      case 'yearly':
        return interval == 1 ? 'Every year' : 'Every $interval years';
      default:
        return 'Custom recurrence';
    }
  }

  void _showHideConfirmation(BuildContext context, Event event) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hide Recurring Event'),
        content: Text('Are you sure you want to hide "${event.title}"? You can access it later from the Hidden Events menu.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final success = await eventController.toggleEventVisibility(event.id, false);
              if (success) Get.back(closeOverlays: true);
            },
            child: const Text('Hide'),
          ),
        ],
      ),
    );
  }
}
