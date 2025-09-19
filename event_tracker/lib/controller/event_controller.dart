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
      final success = await _eventService.updateEventStatus(
        eventId,
        isCancelled: isCancelled,
        isCompleted: isCompleted,
      );

      if (success) {
        // Reload events to get the updated data from server
        await loadEvents();
        
        // Find the updated event
        final updatedEvent = events.firstWhereOrNull((e) => e.id == eventId);

        ModernSnackbar.success(
          title: 'Event Updated',
          message: 'Event status updated successfully',
        );

        return updatedEvent;
      }

      return null;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to update event status';
      ModernSnackbar.error(
        title: 'Update Failed',
        message: errorMessage,
      );
      return null;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Update Failed',
        message: 'Failed to update event status',
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
    } on DioException catch (e) {
      final errorMessage = e.response?.data is Map ? 
          (e.response?.data['message']?.toString() ?? 'Failed to load events') : 
          'Failed to load events';
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: errorMessage,
      );
    } catch (e) {
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: 'Failed to load events',
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
    String? address,
    int? categoryId,
    String? eventType,
    int? maxCapacity,
    bool isRecurring = false,
    String? recurrenceType,
    int recurrenceInterval = 1,
    DateTime? recurrenceEndDate,
  }) async {
    try {
      final userId = Get.find<AuthController>().currentUser.value?.userId;
      if (userId == null) return false;

      final event = Event(
        title: title,
        description: description,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        address: address,
        categoryId: categoryId,
        eventType: eventType,
        maxCapacity: maxCapacity,
        createdBy: userId,
        isRecurring: isRecurring,
        recurrenceType: recurrenceType,
        recurrenceInterval: recurrenceInterval,
        recurrenceEndDate: recurrenceEndDate,
      );

      await _eventService.createEvent(event);
      await loadEvents();
      ModernSnackbar.success(
        title: 'Event Created',
        message: 'Your event has been created successfully',
      );
      return true;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to create event';
      ModernSnackbar.error(
        title: 'Creation Failed',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Creation Failed',
        message: 'Failed to create event',
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
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to update event';
      ModernSnackbar.error(
        title: 'Update Failed',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Update Failed',
        message: 'Failed to update event',
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
        ModernSnackbar.success(
          title: 'Visibility Updated',
          message: isVisible ? 'Event is now visible' : 'Event is now hidden',
        );
      }
      return success;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to update event visibility';
      ModernSnackbar.error(
        title: 'Update Failed',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Update Failed',
        message: 'Failed to update event visibility',
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
    } on DioException catch (e) {
      final errorMessage = e.response?.data is Map ? 
          (e.response?.data['message']?.toString() ?? 'Failed to load hidden events') : 
          'Failed to load hidden events';
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: errorMessage,
      );
    } catch (e) {
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: 'Failed to load hidden events',
      );
    }
  }

  // Get single event by ID
  Future<Event?> getEventById(String eventId) async {
    try {
      return await _eventService.getEventById(eventId);
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to load event details';
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: errorMessage,
      );
      return null;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: 'Failed to load event details',
      );
      return null;
    }
  }
}
