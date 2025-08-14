import '../utils/import_export.dart';

class InviteController extends GetxController {
  final InviteService _inviteService = InviteService();
  final RxList<UserModel> searchResults = <UserModel>[].obs;
  final RxList<EventUserModel> eventInvites = <EventUserModel>[].obs;
  final RxList<EventUserModel> userInvites = <EventUserModel>[].obs;
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
      Get.snackbar(
        'Error',
        'Failed to search users',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create event invite
  Future<bool> createEventInvite(String eventId, String userId) async {
    try {
      final invite = EventUserModel(
        eventId: eventId,
        userId: userId,
        status: 'pending',
        createdAt: DateTime.now().toIso8601String(),
      );

      final success = await _inviteService.createEventInvite(invite);
      
      if (success) {
        Get.snackbar(
          'Success',
          'Invite sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await loadEventInvites(eventId);
      }
      
      return success;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send invite',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Load invites for an event
  Future<void> loadEventInvites(String eventId) async {
    isLoading.value = true;
    try {
      final invites = await _inviteService.getEventInvites(eventId);
      eventInvites.value = invites;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load event invites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
        final invites = await _inviteService.getUserInvites(currentUser.userId);
        userInvites.value = invites;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load your invites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update invite status
  Future<bool> updateInviteStatus(String eventId, String userId, String status, {String? note}) async {
    try {
      final success = await _inviteService.updateInviteStatus(eventId, userId, status, note: note);
      
      if (success) {
        await loadUserInvites();
        Get.snackbar(
          'Success',
          'Invite status updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      return success;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update invite status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Check if user is invited to event
  Future<bool> isUserInvitedToEvent(String eventId) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        return await _inviteService.isUserInvitedToEvent(eventId, currentUser.userId);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get invite details for current user
  Future<EventUserModel?> getInviteDetails(String eventId) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        return await _inviteService.getInviteDetails(eventId, currentUser.userId);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Delete invite
  Future<bool> deleteInvite(String eventId, String userId) async {
    try {
      final success = await _inviteService.deleteInvite(eventId, userId);
      
      if (success) {
        await loadEventInvites(eventId);
        Get.snackbar(
          'Success',
          'Invite deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      return success;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete invite',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Get filtered invites based on status
  List<EventUserModel> getFilteredInvites() {
    if (selectedStatus.value == 'all') {
      return userInvites;
    }
    return userInvites.where((invite) => invite.status == selectedStatus.value).toList();
  }

  // Load events that user is invited to (for home page)
  final RxList<Map<String, dynamic>> invitedEvents = <Map<String, dynamic>>[].obs;

  Future<void> loadInvitedEvents() async {
    isLoading.value = true;
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        final events = await _inviteService.getEventsUserIsInvitedTo(currentUser.userId);
        invitedEvents.value = events;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load invited events',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get user's role for a specific event
  Future<EventUserModel?> getUserRoleForEvent(String eventId) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        return await _inviteService.getUserRoleForEvent(eventId, currentUser.userId);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get event details with invite info
  Future<Map<String, dynamic>> getEventWithInviteInfo(String eventId) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser != null) {
        return await _inviteService.getEventWithInviteInfo(eventId, currentUser.userId);
      }
      return {'event': null, 'invite': null};
    } catch (e) {
      return {'event': null, 'invite': null};
    }
  }

  // Clear search results
  void clearSearch() {
    searchResults.clear();
    searchQuery.value = '';
  }
} 