import '../utils/import_export.dart';

class InvisibleEventsPage extends StatelessWidget {
  final EventController _eventController = Get.find<EventController>();

  InvisibleEventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Load invisible events when page is built
    _eventController.loadInvisibleEvents();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hidden Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _eventController.loadInvisibleEvents(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(
        () => _eventController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _eventController.invisibleEvents.isEmpty
                ? const Center(
                    child: Text('No hidden events'),
                  )
                : ListView.builder(
                    itemCount: _eventController.invisibleEvents.length,
                    itemBuilder: (context, index) {
                      final event = _eventController.invisibleEvents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(event.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.description),
                              const SizedBox(height: 4),
                              Text(
                                'Start: ${DateFormat('MMM d, y h:mm a').format(event.startDateTime)}',
                              ),
                              if (event.endDateTime != null)
                                Text(
                                  'End: ${DateFormat('MMM d, y h:mm a').format(event.endDateTime!)}',
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () async {
                              // Immediately remove from local list for instant UI update
                              _eventController.invisibleEvents.removeWhere((e) => e.id == event.id);
                              
                              final success = await _eventController.toggleEventVisibility(event.id, true);
                              if (!success) {
                                // If failed, add it back to the list
                                _eventController.invisibleEvents.add(event);
                                ModernSnackbar.error(
                                  title: 'Failed',
                                  message: 'Failed to make event visible',
                                );
                              }
                            },
                            tooltip: 'Make visible',
                          ),
                          onTap: () => Get.toNamed(
                            AppRoutes.eventDetails,
                            arguments: event,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
