import '../utils/import_export.dart';
import '../utils/api_constants.dart';

class InviteService {
  final Dio _dio = Get.find<Dio>();
  final String baseUrl = ApiConstants.baseUrl;

  // Search users by phone number
  Future<List<UserModel>> searchUsersByPhone(String phone) async {
    try {
      final response = await _dio.get(
        '$baseUrl/auth/users/search',
        queryParameters: {'phone': phone},
      );

      final List<dynamic> data = response.data;
      return data.map((json) => UserModel(
        userId: json['UserId'] ?? json['userId'] ?? '',
        name: json['Name'] ?? json['name'] ?? '',
        email: json['Email'] ?? json['email'] ?? '',
        phone: json['Phone'] ?? json['phone'],
        isActive: true, // Search only returns active users
        createdAt: DateTime.now(), // Default value since not provided in search
      )).toList();
    } catch (e) {
      print('Error in searchUsersByPhone: $e');
      rethrow;
    }
  }

  // Create event invite
  Future<bool> createEventInvite(EventInviteModel invite) async {
    try {
      print('Creating invite with data: ${invite.toJson()}');
      final response = await _dio.post(
        '$baseUrl/event-invites',
        data: {
          'eventId': invite.eventId,
          'invitedUserId': invite.invitedUserId,
          'participantCount': invite.participantCount,
        },
      );
      print('Invite creation response: ${response.statusCode} - ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('DioException creating invite: ${e.response?.statusCode} - ${e.response?.data}');
      print('Error message: ${e.message}');
      return false;
    } catch (e) {
      print('Error creating invite: $e');
      return false;
    }
  }

  // Get invites for a user
  Future<List<EventInviteModel>> getEventInvites(String userId) async {
    try {
      print('Loading user invites for userId: $userId');
      final response = await _dio.get('$baseUrl/event-invites/user/$userId');
      print('User invites response: ${response.statusCode}');
      final data = response.data;
      if (data is List) {
        return data.map((json) {
          try {
            return EventInviteModel.fromJson(json);
          } catch (e) {
            print('Invite parse error: $e; json=$json');
            return null;
          }
        }).whereType<EventInviteModel>().toList();
      }
      return <EventInviteModel>[];
    } catch (e) {
      print('Error loading user invites: $e');
      return <EventInviteModel>[];
    }
  }

  // Get invites for a user (full list)
  Future<List<EventInviteModel>> getUserInvites(String userId) async {
    try {
      print('Loading user invites for userId: $userId');
      final response = await _dio.get('$baseUrl/event-invites/user/$userId');
      print('User invites response: ${response.statusCode}');
      final data = response.data;
      if (data is List) {
        return data.map((json) {
          try {
            return EventInviteModel.fromJson(json);
          } catch (e) {
            print('Invite parse error: $e; json=$json');
            return null;
          }
        }).whereType<EventInviteModel>().toList();
      }
      return <EventInviteModel>[];
    } catch (e) {
      print('Error loading user invites: $e');
      return <EventInviteModel>[];
    }
  }

  // Get pending invites for a user
  Future<List<EventInviteModel>> getUserPendingInvites(String userId) async {
    try {
      print('Loading pending invites for userId: $userId');
      final response = await _dio.get('$baseUrl/event-invites/pending/user/$userId');
      print('Pending invites response: ${response.statusCode}');
      final data = response.data;
      if (data is List) {
        return data.map((json) {
          try {
            return EventInviteModel.fromJson(json);
          } catch (e) {
            print('Invite parse error: $e; json=$json');
            return null;
          }
        }).whereType<EventInviteModel>().toList();
      }
      return <EventInviteModel>[];
    } catch (e) {
      print('Error loading pending invites: $e');
      return <EventInviteModel>[];
    }
  }

  // Update invite status
  Future<bool> updateInviteStatus(String inviteId, String status) async {
    try {
      print('Updating invite status: inviteId=$inviteId, status=$status');
      final response = await _dio.put(
        '$baseUrl/event-invites/$inviteId/status',
        data: {'status': status},
      );
      print('Update invite status response: ${response.statusCode} - ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('DioException updating invite status: ${e.response?.statusCode} - ${e.response?.data}');
      print('Error message: ${e.message}');
      return false;
    } catch (e) {
      print('Error updating invite status: $e');
      return false;
    }
  }

  // Update invite status with participant count
  Future<bool> updateInviteStatusWithParticipants(String inviteId, String status, int participantCount) async {
    try {
      print('Updating invite status with participants: inviteId=$inviteId, status=$status, participantCount=$participantCount');
      final response = await _dio.put(
        '$baseUrl/event-invites/$inviteId/status',
        data: {
          'status': status,
          'participantCount': participantCount,
        },
      );
      print('Update invite status response: ${response.statusCode} - ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('DioException updating invite status: ${e.response?.statusCode} - ${e.response?.data}');
      print('Error message: ${e.message}');
      return false;
    } catch (e) {
      print('Error updating invite status: $e');
      return false;
    }
  }

  // Check if user is invited to event
  Future<bool> isUserInvitedToEvent(String eventId, String userId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/event-invites',
        queryParameters: {
          'eventId': eventId,
          'userId': userId,
        },
      );
      final List<dynamic> invites = response.data;
      return invites.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get invite details
  Future<EventInviteModel?> getInviteDetails(String eventId, String userId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/event-invites',
        queryParameters: {
          'eventId': eventId,
          'userId': userId,
        },
      );
      final List<dynamic> invites = response.data;
      if (invites.isNotEmpty) {
        return EventInviteModel.fromJson(invites.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Delete invite
  Future<bool> deleteInvite(String inviteId) async {
    try {
      final response = await _dio.delete('$baseUrl/event-invites/$inviteId');
      return response.statusCode == 204;
    } on DioException catch (e) {
      print('Error deleting invite: ${e.message}');
      return false;
    }
  }

  // Get event details with invite information
  Future<Map<String, dynamic>?> getEventWithInviteInfo(String eventId, String userId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/event-invites',
        queryParameters: {
          'eventId': eventId,
          'userId': userId,
        },
      );
      
      final List<dynamic> invites = response.data;
      if (invites.isNotEmpty) {
        final invite = EventInviteModel.fromJson(invites.first);
        return {
          'event': invite.event,
          'invite': invite,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get accepted invites for a specific event
  Future<List<EventInviteModel>> getAcceptedInvitesForEvent(String eventId) async {
    try {
      print('Loading accepted invites for event: $eventId');
      final response = await _dio.get('$baseUrl/event-invites', queryParameters: {'eventId': eventId});
      print('Event invites response: ${response.statusCode} - ${response.data}');
      
      final List<dynamic> data = response.data;
      final allInvites = data.map((json) => EventInviteModel.fromJson(json)).toList();
      
      // Filter only accepted invites
      final acceptedInvites = allInvites.where((invite) => invite.status == InviteStatus.accepted).toList();
      print('Found ${acceptedInvites.length} accepted invites for event $eventId');
      
      return acceptedInvites;
    } catch (e) {
      print('Error loading accepted invites for event: $e');
      rethrow;
    }
  }

  // Get events that user is invited to (for home page display)
  Future<List<Map<String, dynamic>>> getEventsUserIsInvitedTo(String userId) async {
    final invites = await getUserInvites(userId);
    return invites.where((invite) => 
      invite.status == InviteStatus.accepted && 
      invite.event != null &&
      invite.event!.createdBy != userId
    ).map((invite) => {
      'event': invite.event!,
      'invite': invite,
    }).toList();
  }
}