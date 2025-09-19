import '../utils/import_export.dart';
import '../utils/api_constants.dart';

class EventInviteService {
  final Dio _dio = Get.find<Dio>();
  final String baseUrl = ApiConstants.baseUrl;

  // Create Event Invite
  Future<EventInviteModel> createEventInvite(EventInviteModel invite) async {
    final response = await _dio.post(
      '$baseUrl${ApiConstants.createInvite}',
      data: invite.toJson(),
    );

    return EventInviteModel.fromJson(response.data);
  }

  // Get Event Invites by Event ID
  Future<List<EventInviteModel>> getEventInvitesByEventId(String eventId) async {
    final response = await _dio.get(
      '$baseUrl${ApiConstants.invites}/event/$eventId',
    );

    final List<dynamic> data = response.data;
    return data.map((json) => EventInviteModel.fromJson(json)).toList();
  }

  // Get Event Invites by Phone Number
  Future<List<EventInviteModel>> getEventInvitesByPhone(String phone) async {
    final response = await _dio.get(
      '$baseUrl${ApiConstants.userInvites}/$phone',
    );

    final List<dynamic> data = response.data;
    return data.map((json) => EventInviteModel.fromJson(json)).toList();
  }

  // Get Pending Event Invites by Phone Number
  Future<List<EventInviteModel>> getPendingEventInvitesByPhone(String phone) async {
    final response = await _dio.get(
      '$baseUrl${ApiConstants.pendingUserInvites}/$phone',
    );

    final List<dynamic> data = response.data;
    return data.map((json) => EventInviteModel.fromJson(json)).toList();
  }

  // Update Event Invite Status
  Future<bool> updateEventInviteStatus(String inviteId, String status) async {
    try {
      final endpoint = ApiConstants.updateInviteStatus.replaceAll('{inviteId}', inviteId);
      print('Updating invite status at endpoint: $endpoint');
      await _dio.put(
        '$baseUrl$endpoint',
        data: {'status': status},
      );
      return true;
    } catch (e) {
      print('Error updating invite status: $e');
      return false;
    }
  }

  // Delete Event Invite
  Future<bool> deleteEventInvite(String inviteId) async {
    try {
      final endpoint = ApiConstants.deleteInvite.replaceAll('{inviteId}', inviteId);
      await _dio.delete('$baseUrl$endpoint');
      return true;
    } catch (e) {
      print('Error deleting invite: $e');
      return false;
    }
  }

  // Check if user is invited to event
  Future<bool> isUserInvitedToEvent(String eventId, String phone) async {
    try {
      final response = await _dio.get(
        '$baseUrl${ApiConstants.invites}/check',
        queryParameters: {
          'eventId': eventId,
          'phone': phone,
        },
      );
      return response.data['isInvited'] as bool;
    } catch (e) {
      print('Error checking if user is invited: $e');
      return false;
    }
  }

  // Get Event Invite by ID
  Future<EventInviteModel?> getEventInviteById(String inviteId) async {
    try {
      final response = await _dio.get('$baseUrl${ApiConstants.invites}/$inviteId');
      return EventInviteModel.fromJson(response.data);
    } catch (e) {
      print('Error getting invite by ID: $e');
      return null;
    }
  }
}
