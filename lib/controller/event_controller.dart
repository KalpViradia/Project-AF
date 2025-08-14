import '../utils/import_export.dart';

class EventController extends GetxController {
  final EventService _eventService = EventService();
  final RxList<Event> events = <Event>[].obs;
  final RxList<Event> invisibleEvents = <Event>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    debounce(
      searchQuery,
      (_) => loadEvents(),
      time: const Duration(milliseconds: 500),
    );
    loadEvents();
    loadInvisibleEvents();
  }

  Future<Event?> toggleEventStatus(String eventId, {bool? isCancelled, bool? isCompleted}) async {
    try {
      final event = events.firstWhere((e) => e.id == eventId);

      final updatedEvent = Event(
        id: event.id,
        title: event.title,
        description: event.description,
        startDateTime: event.startDateTime,
        endDateTime: event.endDateTime,
        latitude: event.latitude,
        longitude: event.longitude,
        address: event.address,
        categoryId: event.categoryId,
        eventType: event.eventType,
        coverImageUrl: event.coverImageUrl,
        maxCapacity: event.maxCapacity,
        createdBy: event.createdBy,
        isCancelled: isCancelled ?? event.isCancelled,
        isCompleted: isCompleted ?? event.isCompleted,
        createdAt: event.createdAt,
        updatedAt: DateTime.now(),
      );

      final success = await _eventService.updateEvent(updatedEvent);

      if (success) {
        // update the event in-place in the list
        final index = events.indexWhere((e) => e.id == eventId);
        if (index != -1) {
          events[index] = updatedEvent;
        }

        Get.snackbar(
          'Success',
          'Event status updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return updatedEvent;
      }

      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update event status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<void> loadEvents() async {
    isLoading.value = true;
    try {
      final userId = Get.find<AuthController>().currentUser.value?.userId;
      final query = searchQuery.value.trim();
      events.value = await _eventService.getEvents(
        userId: userId,
        searchQuery: query.isNotEmpty ? query : null,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load events',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime startDateTime,
    DateTime? endDateTime,
    double? latitude,
    double? longitude,
    String? address,
    int? categoryId,
    String? eventType,
    String? coverImageUrl,
    int? maxCapacity,
  }) async {
    try {
      final userId = Get.find<AuthController>().currentUser.value?.userId;
      if (userId == null) return false;

      final event = Event(
        title: title,
        description: description,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        latitude: latitude,
        longitude: longitude,
        address: address,
        categoryId: categoryId,
        eventType: eventType,
        coverImageUrl: coverImageUrl,
        maxCapacity: maxCapacity,
        createdBy: userId,
      );

      final newEvent = await _eventService.createEvent(event);
      if (newEvent != null) {
        await loadEvents();
        Get.snackbar(
          'Success',
          'Event created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create event',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> updateEvent(Event event) async {
    try {
      final success = await _eventService.updateEvent(event);

      if (success) {
        await loadEvents();
      }
      return success;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update event',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> toggleEventVisibility(String eventId, bool isVisible) async {
    try {
      final success = await _eventService.toggleEventVisibility(eventId, isVisible);
      if (success) {
        await Future.wait([
          loadEvents(),
          loadInvisibleEvents(),
        ]);
        Get.snackbar(
          'Success',
          isVisible ? 'Event is now visible' : 'Event is now hidden',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      return success;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update event visibility',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> loadInvisibleEvents() async {
    try {
      final userId = Get.find<AuthController>().currentUser.value?.userId;
      invisibleEvents.value = await _eventService.getInvisibleEvents(
        userId: userId,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load invisible events',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get single event by ID
  Future<Event?> getEventById(String eventId) async {
    try {
      return await _eventService.getEventById(eventId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load event',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
}
