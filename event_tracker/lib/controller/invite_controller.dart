import '../utils/import_export.dart';

class InviteController extends GetxController {
  final InviteService _inviteService = InviteService();
  final RxList<UserModel> searchResults = <UserModel>[].obs;
  final RxList<EventInviteModel> eventInvites = <EventInviteModel>[].obs;
  final RxList<EventInviteModel> userInvites = <EventInviteModel>[].obs;
  final RxList<EventInviteModel> pendingInvites = <EventInviteModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(
      searchQuery,
      (_) => searchUsers(),
      time: const Duration(milliseconds: 500),
    );
  }

  String? _extractErrorMessage(dynamic data) {
    try {
      if (data == null) return null;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data as Map);
        return map['message']?.toString() ?? map['error']?.toString();
      }
      return data.toString();
    } catch (_) {
      return null;
    }
  }

  // Search users by phone number
  Future<void> searchUsers() async {
    if (searchQuery.value.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;
    try {
      final results = await _inviteService.searchUsersByPhone(searchQuery.value.trim());
      searchResults.value = results;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Search Failed',
        message: 'Failed to search users',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create event invite
  Future<bool> createEventInvite(String eventId, String userId) async {
    return createEventInviteWithParticipants(eventId, userId, 1);
  }

  // Create event invite with participant count
  Future<bool> createEventInviteWithParticipants(String eventId, String userId, int participantCount) async {
    try {
      // First check if user is already invited
      final existing = await _inviteService.getInviteDetails(eventId, userId);
      if (existing != null) {
        if (existing.isAccepted) {
          ModernSnackbar.error(
            title: 'Already Invited',
            message: 'User is already a member of this event',
          );
        } else if (existing.isPending) {
          ModernSnackbar.error(
            title: 'Already Invited',
            message: 'User already has a pending invitation',
          );
        } else if (existing.isDeclined) {
          // If declined, create a new invite
          await _inviteService.deleteInvite(existing.id);
        }
        return false;
      }

      // Check event capacity before creating invite
      try {
        final capacityInfo = await Get.find<EventService>().getEventCapacityInfo(eventId);
        final availableSpaces = capacityInfo['availableSpaces'] as int;
        
        if (availableSpaces < participantCount) {
          ModernSnackbar.error(
            title: 'Capacity Exceeded',
            message: 'Only $availableSpaces spaces available. Cannot invite $participantCount participants.',
          );
          return false;
        }
      } catch (e) {
        print('Error checking capacity: $e');
        // Continue with invite creation if capacity check fails
      }

      final invite = EventInviteModel(
        id: const Uuid().v4(),
        eventId: eventId,
        invitedUserId: userId,
        status: InviteStatus.pending,
        participantCount: participantCount,
        createdAt: DateTime.now(),
      );

      final success = await _inviteService.createEventInvite(invite);
      
      if (success) {
        ModernSnackbar.success(
          title: 'Invite Sent',
          message: 'Invitation sent successfully for $participantCount participant${participantCount > 1 ? 's' : ''}',
        );
        await loadEventInvites(eventId);
      }
      
      return success;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to send invitation';
      ModernSnackbar.error(
        title: 'Invite Failed',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Invite Failed',
        message: 'Failed to send invitation',
      );
      return false;
    }
  }

  // Load invites for a user (renamed for clarity)
  Future<void> loadEventInvites(String userId) async {
    isLoading.value = true;
    try {
      final invites = await _inviteService.getEventInvites(userId);
      eventInvites.value = invites;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to load user invites';
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: errorMessage,
      );
    } catch (e) {
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: 'Failed to load user invites',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load invites for current user
  Future<void> loadUserInvites() async {
    isLoading.value = true;
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        print('Loading invites for user: ${currentUser.userId}');
        
        // Load all user invites
        final allInvites = await _inviteService.getUserInvites(currentUser.userId);
        print('Loaded ${allInvites.length} user invites');
        userInvites.value = allInvites;

        // Separately load pending invites
        final pendingInvs = await _inviteService.getUserPendingInvites(currentUser.userId);
        print('Loaded ${pendingInvs.length} pending invites');
        pendingInvites.value = pendingInvs;
        
        print('User invites loaded successfully');
      } else {
        print('No current user found');
      }
    } on DioException catch (e) {
      print('DioException loading user invites: ${e.response?.statusCode} - ${e.response?.data}');
      final errorMessage = _extractErrorMessage(e.response?.data) ?? 'Failed to load your invitations';
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: errorMessage,
      );
    } catch (e) {
      print('Error loading user invites: $e');
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: 'Failed to load your invitations',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update invite status
  Future<bool> updateInviteStatus(String inviteId, InviteStatus status) async {
    try {
      final success = await _inviteService.updateInviteStatus(inviteId, status.value);
      
      if (success) {
        await loadUserInvites();
        ModernSnackbar.success(
          title: 'Success',
          message: 'Invite status updated',
        );
      }
      
      return success;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to update invite status';
      ModernSnackbar.error(
        title: 'Update Failed',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Update Failed',
        message: 'Failed to update invite status',
      );
      return false;
    }
  }

  // Update invite status with participant count
  Future<bool> updateInviteStatusWithParticipants(String inviteId, InviteStatus status, int participantCount) async {
    try {
      final success = await _inviteService.updateInviteStatusWithParticipants(inviteId, status.value, participantCount);
      
      if (success) {
        await loadUserInvites();
        ModernSnackbar.success(
          title: 'Success',
          message: 'Invite updated for $participantCount participant${participantCount > 1 ? 's' : ''}',
        );
      }
      
      return success;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to update invite';
      ModernSnackbar.error(
        title: 'Update Failed',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Update Failed',
        message: 'Failed to update invite',
      );
      return false;
    }
  }

  // Check if user is invited to event
  Future<bool> isUserInvitedToEvent(String eventId) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        final invites = await _inviteService.getUserInvites(currentUser.userId);
        return invites.any((invite) => invite.eventId == eventId);
      }
      return false;
    } on DioException {
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get invite details for current user
  Future<EventInviteModel?> getInviteDetails(String eventId) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        return await _inviteService.getInviteDetails(eventId, currentUser.userId);
      }
      return null;
    } on DioException catch (e) {
      ModernSnackbar.error(
        title: 'Error',
        message: e.response?.data['message'] ?? 'Failed to get invite details',
      );
      return null;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Error',
        message: 'Failed to get invite details',
      );
      return null;
    }
  }

  // Delete invite
  Future<bool> deleteInvite(String inviteId) async {
    try {
      final success = await _inviteService.deleteInvite(inviteId);
      
      if (success) {
        await loadUserInvites();
        ModernSnackbar.success(
          title: 'Success',
          message: 'Invite deleted successfully',
        );
      }
      
      return success;
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e.response?.data) ?? 'Failed to delete invite';
      ModernSnackbar.error(
        title: 'Delete Failed',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Delete Failed',
        message: 'Failed to delete invite',
      );
      return false;
    }
  }

  // Get filtered invites based on status
  List<EventInviteModel> getFilteredInvites() {
    if (selectedStatus.value == 'all') {
      return userInvites;
    }
    final filterStatus = InviteStatusExtension.fromString(selectedStatus.value);
    return userInvites.where((invite) => invite.status == filterStatus).toList();
  }

  // Load events that user is invited to (for home page)
  final RxList<Map<String, dynamic>> invitedEvents = <Map<String, dynamic>>[].obs;
  final RxList<Event> acceptedEvents = <Event>[].obs;
  final RxList<EventInviteModel> acceptedEventInvites = <EventInviteModel>[].obs;

  Future<void> loadInvitedEvents() async {
    isLoading.value = true;
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        // Get all events user is invited to
        final events = await _inviteService.getEventsUserIsInvitedTo(currentUser.userId);
        invitedEvents.value = events;

        // Update the accepted events list
        acceptedEvents.value = events
          .where((e) => e['invite'] != null && 
            e['invite'].status == InviteStatus.accepted)
          .map((e) => e['event'] as Event)
          .toList();
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e.response?.data) ?? 'Failed to load invited events';
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: errorMessage,
      );
    } catch (e) {
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: 'Failed to load invited events',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load accepted invites for a specific event
  Future<void> loadAcceptedEventInvites(String eventId) async {
    isLoading.value = true;
    try {
      print('Loading accepted invites for event: $eventId');
      final invites = await _inviteService.getAcceptedInvitesForEvent(eventId);
      acceptedEventInvites.value = invites;
      print('Loaded ${invites.length} accepted invites');
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to load accepted invites';
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: errorMessage,
      );
    } catch (e) {
      print('Error loading accepted invites: $e');
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: 'Failed to load accepted invites',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear search results
  void clearSearch() {
    searchResults.clear();
    searchQuery.value = '';
  }
} 