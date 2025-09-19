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
      if (currentUser?.phone != null && currentUser?.phone?.isNotEmpty == true) {
        eventInvites.value = await _eventInviteService.getEventInvitesByPhone(currentUser!.phone!);
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to load event invitations';
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: errorMessage,
      );
    } catch (e) {
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: 'Failed to load event invitations',
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
      if (currentUser?.phone != null && currentUser?.phone?.isNotEmpty == true) {
        eventInvites.value = await _eventInviteService.getPendingEventInvitesByPhone(currentUser!.phone!);
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to load pending event invites';
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: errorMessage,
      );
    } catch (e) {
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: 'Failed to load pending event invites',
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
        id: const Uuid().v4(),
        eventId: eventId,
        invitedUserId: const Uuid().v4(),
        status: InviteStatus.pending,
        participantCount: 1,
        createdAt: DateTime.now(),
      );

      await _eventInviteService.createEventInvite(invite);
      
      ModernSnackbar.success(
        title: 'Invite Sent',
        message: 'Event invite sent successfully',
      );
      
      return true;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to send event invite';
      ModernSnackbar.error(
        title: 'Invite Failed',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Invite Failed',
        message: 'Failed to send event invite',
      );
      return false;
    }
  }

  // Update invite status
  Future<bool> updateInviteStatus(String inviteId, InviteStatus status) async {
    try {
      final success = await _eventInviteService.updateEventInviteStatus(inviteId, status.value);
      
      if (success) {
        await loadEventInvites();
        ModernSnackbar.success(
          title: 'Status Updated',
          message: 'Invite status updated successfully',
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

  // Delete event invite
  Future<bool> deleteEventInvite(String inviteId) async {
    try {
      final success = await _eventInviteService.deleteEventInvite(inviteId);
      
      if (success) {
        await loadEventInvites();
        ModernSnackbar.success(
          title: 'Invite Removed',
          message: 'Event invitation deleted successfully',
        );
      }
      
      return success;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to delete event invitation';
      ModernSnackbar.error(
        title: 'Delete Failed',
        message: errorMessage,
      );
      return false;
    } catch (e) {
      ModernSnackbar.error(
        title: 'Delete Failed',
        message: 'Failed to delete event invitation',
      );
      return false;
    }
  }

  // Check if user is invited to event
  Future<bool> isUserInvitedToEvent(String eventId) async {
    try {
      final currentUser = Get.find<AuthController>().currentUser.value;
      if (currentUser?.phone != null && currentUser?.phone?.isNotEmpty == true) {
        return await _eventInviteService.isUserInvitedToEvent(eventId, currentUser!.phone!);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Validate phone number format
  bool _validatePhoneNumber(String phone) {
    // Enhanced phone number validation with country code support
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone);
  }

  // Get event invites by event ID
  Future<List<EventInviteModel>> getEventInvitesByEventId(String eventId) async {
    try {
      return await _eventInviteService.getEventInvitesByEventId(eventId);
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Failed to load event invitations';
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: errorMessage,
      );
      return [];
    } catch (e) {
      ModernSnackbar.error(
        title: 'Loading Failed',
        message: 'Failed to load event invitations',
      );
      return [];
    }
  }
}
