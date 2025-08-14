import '../utils/import_export.dart';

class EventInviteController extends GetxController {
  final EventInviteService _eventInviteService = EventInviteService();
  final RxList<EventInviteModel> eventInvites = <EventInviteModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString phoneError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadEventInvites();
  }

  // Load event invites for current user
  Future<void> loadEventInvites() async {
    isLoading.value = true;
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser?.phone != null) {
        eventInvites.value = await _eventInviteService.getEventInvitesByPhone(currentUser!.phone);
      }
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

  // Load pending event invites for current user
  Future<void> loadPendingEventInvites() async {
    isLoading.value = true;
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser?.phone != null) {
        eventInvites.value = await _eventInviteService.getPendingEventInvitesByPhone(currentUser!.phone);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load pending event invites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create event invite by phone number
  Future<bool> createEventInvite(String eventId, String phone) async {
    try {
      // Validate phone number
      if (!_validatePhoneNumber(phone)) {
        phoneError.value = 'Please enter a valid phone number';
        return false;
      }
      phoneError.value = '';

      final invite = EventInviteModel(
        inviteId: const Uuid().v4(),
        eventId: eventId,
        phone: phone,
        status: 'pending',
        invitedAt: DateTime.now().toIso8601String(),
      );

      await _eventInviteService.createEventInvite(invite);
      
      Get.snackbar(
        'Success',
        'Event invite sent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send event invite',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Update invite status
  Future<bool> updateInviteStatus(String inviteId, String status) async {
    try {
      final success = await _eventInviteService.updateEventInviteStatus(inviteId, status);
      
      if (success) {
        await loadEventInvites();
        Get.snackbar(
          'Success',
          'Invite status updated successfully',
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

  // Delete event invite
  Future<bool> deleteEventInvite(String inviteId) async {
    try {
      final success = await _eventInviteService.deleteEventInvite(inviteId);
      
      if (success) {
        await loadEventInvites();
        Get.snackbar(
          'Success',
          'Event invite deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      return success;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete event invite',
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
      if (currentUser?.phone != null) {
        return await _eventInviteService.isUserInvitedToEvent(eventId, currentUser!.phone);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Validate phone number format
  bool _validatePhoneNumber(String phone) {
    // Basic phone number validation - can be enhanced based on requirements
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    return phoneRegex.hasMatch(phone) && phone.length >= 10;
  }

  // Get event invites by event ID
  Future<List<EventInviteModel>> getEventInvitesByEventId(String eventId) async {
    try {
      return await _eventInviteService.getEventInvitesByEventId(eventId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load event invites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return [];
    }
  }
}
