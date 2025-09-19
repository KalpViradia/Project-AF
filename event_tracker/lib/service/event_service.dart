import '../utils/import_export.dart';
import '../utils/api_constants.dart';

class EventService {
  final Dio _dio = Get.find<Dio>();
  final String baseUrl = ApiConstants.baseUrl;

  // Create Event
  Future<Event> createEvent(Event event) async {
    final response = await _dio.post(
      '$baseUrl/Events',
      data: event.toJson(),
    );
    return Event.fromJson(response.data);
  }

  // Read Events (with optional search)
  Future<List<Event>> getEvents({String? userId, String? searchQuery}) async {
    Map<String, dynamic> queryParams = {};
    
    if (userId != null) {
      queryParams['userId'] = userId;
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search'] = searchQuery;
    }

    final response = await _dio.get(
      '$baseUrl/Events',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Event.fromJson(json)).toList();
  }

  // Get Single Event
  Future<Event?> getEventById(String eventId) async {
    try {
      final response = await _dio.get('$baseUrl/Events/$eventId');
      return Event.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  // Update Event
  Future<bool> updateEvent(Event event) async {
    try {
      print('Updating event with ID: ${event.id}');
      print('Event data: ${event.toJson()}');
      final response = await _dio.put(
        '$baseUrl/Events/${event.id}',
        data: event.toJson(),
      );
      print('Update response: ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating event: $e');
      rethrow;  // Rethrow to allow proper error handling upstream
    }
  }

  // Toggle Event Visibility
  Future<bool> toggleEventVisibility(String id, bool isVisible) async {
    try {
      await _dio.patch(
        '$baseUrl/Events/$id/visibility',
        data: {'isVisible': isVisible},
      );
      return true;
    } catch (e) {
      print('Error toggling event visibility: $e');
      return false;
    }
  }

  // Update Event Status (Cancelled/Completed)
  Future<bool> updateEventStatus(String id, {bool? isCancelled, bool? isCompleted}) async {
    try {
      Map<String, dynamic> data = {};
      if (isCancelled != null) data['isCancelled'] = isCancelled;
      if (isCompleted != null) data['isCompleted'] = isCompleted;
      
      await _dio.patch(
        '$baseUrl/Events/$id/status',
        data: data,
      );
      return true;
    } catch (e) {
      print('Error updating event status: $e');
      return false;
    }
  }

  // Get Invisible Events
  Future<List<Event>> getInvisibleEvents({String? userId}) async {
    Map<String, dynamic> queryParams = {};
    
    if (userId != null) {
      queryParams['userId'] = userId;
    }

    final response = await _dio.get(
      '$baseUrl/Events/invisible',
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data;
    return data.map((json) => Event.fromJson(json)).toList();
  }

  // Delete Event
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _dio.delete('$baseUrl/Events/$eventId');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get event capacity information from backend API
  Future<Map<String, dynamic>> getEventCapacityInfo(String eventId) async {
    try {
      final response = await _dio.get('$baseUrl/Events/$eventId/capacity');
      
      final data = response.data;
      print('Capacity API response for event $eventId: $data');
      
      return {
        'eventId': (data['EventId'] ?? data['eventId']) ?? eventId,
        'maxCapacity': (data['MaxCapacity'] ?? data['maxCapacity']) ?? 0,
        'acceptedParticipants': (data['AcceptedParticipants'] ?? data['acceptedParticipants']) ?? 0,
        'availableSpaces': (data['AvailableSpaces'] ?? data['availableSpaces']) ?? 0,
      };
    } catch (e) {
      print('Error getting event capacity for $eventId: $e');
      rethrow;
    }
  }
}
