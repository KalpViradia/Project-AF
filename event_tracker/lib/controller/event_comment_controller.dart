import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../model/event_comment_model.dart';
import '../utils/api_constants.dart';
import '../widgets/modern_snackbar.dart';

class EventCommentController extends GetxController {
  final RxList<EventComment> comments = <EventComment>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Dio _dio = Get.find<Dio>();
  final String baseUrl = ApiConstants.baseUrl;

  Future<void> loadEventComments(String eventId, {String? commentType, bool silent = false}) async {
    try {
      if (!silent) {
        isLoading.value = true;
      }

      final endpoint = '$baseUrl/EventComments/event/$eventId';
      print('[Comments] GET $endpoint${commentType != null ? ' (type=$commentType)' : ''}');

      final response = await _dio.get(
        endpoint,
        queryParameters: commentType != null ? {'commentType': commentType} : null,
      );

      if (response.statusCode == 200) {
        // Log count only to avoid noisy console
        print('[Comments] GET success (${response.statusCode}).');
        final List<dynamic> data = response.data is List ? response.data as List : <dynamic>[];
        comments.value = data
            .map((e) => EventComment.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        print('[Comments] GET failed (${response.statusCode}): ${response.data}');
        ModernSnackbar.error(
          title: 'Error',
          message: 'Failed to load comments: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[Comments] GET error: $e');
      ModernSnackbar.error(
        title: 'Error',
        message: 'Failed to load comments: $e',
      );
    } finally {
      if (!silent) {
        isLoading.value = false;
      }
    }
  }

  Future<bool> createComment(EventCommentCreateRequest request) async {
    try {
      final url = '$baseUrl/EventComments';
      final body = request.toJson();
      print('[Comments] POST $url');
      print('[Comments] Request: $body');

      final response = await _dio.post(url, data: body);

      if (response.statusCode == 201) {
        print('[Comments] POST success (201). Body: ${response.data}');
        final newComment = EventComment.fromJson(Map<String, dynamic>.from(response.data as Map));
        comments.add(newComment);
        // Keep local list in sync and ordered
        await loadEventComments(request.eventId, silent: true);

        ModernSnackbar.success(
          title: 'Success',
          message: request.commentType == 'announcement'
              ? 'Announcement posted successfully'
              : 'Comment added successfully',
        );
        return true;
      } else {
        print('[Comments] POST failed (${response.statusCode}). Body: ${response.data}');
        final Map<String, dynamic> errorData = (response.data is Map)
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        ModernSnackbar.error(
          title: 'Error',
          message: errorData['message'] ?? 'Failed to create comment',
        );
        return false;
      }
    } catch (e) {
      print('[Comments] POST error: $e');
      ModernSnackbar.error(
        title: 'Error',
        message: 'Failed to create comment: $e',
      );
      return false;
    }
  }

  Future<bool> updateComment(String commentId, EventCommentUpdateRequest request) async {
    try {
      final url = '$baseUrl/EventComments/$commentId';
      final body = request.toJson();
      print('[Comments] PUT $url');
      print('[Comments] Request: $body');

      final response = await _dio.put(url, data: body);

      if (response.statusCode == 200) {
        print('[Comments] PUT success (200). Body: ${response.data}');
        final updatedComment = EventComment.fromJson(Map<String, dynamic>.from(response.data as Map));

        final index = comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          comments[index] = updatedComment;
        }
        // Refresh to ensure ordering and server truth
        await loadEventComments(updatedComment.eventId, silent: true);

        ModernSnackbar.success(
          title: 'Success',
          message: 'Comment updated successfully',
        );
        return true;
      } else {
        print('[Comments] PUT failed (${response.statusCode}). Body: ${response.data}');
        final Map<String, dynamic> errorData = (response.data is Map)
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        ModernSnackbar.error(
          title: 'Error',
          message: errorData['message'] ?? 'Failed to update comment',
        );
        return false;
      }
    } catch (e) {
      print('[Comments] PUT error: $e');
      ModernSnackbar.error(
        title: 'Error',
        message: 'Failed to update comment: $e',
      );
      return false;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      String? eventId;
      final idx = comments.indexWhere((c) => c.id == commentId);
      if (idx != -1) {
        eventId = comments[idx].eventId;
      }

      final url = '$baseUrl/EventComments/$commentId';
      print('[Comments] DELETE $url');
      final response = await _dio.delete(url);

      if (response.statusCode == 204) {
        print('[Comments] DELETE success (204).');
        comments.removeWhere((c) => c.id == commentId);
        if (eventId != null && eventId.isNotEmpty) {
          await loadEventComments(eventId, silent: true);
        }

        ModernSnackbar.success(
          title: 'Success',
          message: 'Comment deleted successfully',
        );
        return true;
      } else {
        print('[Comments] DELETE failed (${response.statusCode}). Body: ${response.data}');
        final Map<String, dynamic> errorData = (response.data is Map)
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        ModernSnackbar.error(
          title: 'Error',
          message: errorData['message'] ?? 'Failed to delete comment',
        );
        return false;
      }
    } catch (e) {
      print('[Comments] DELETE error: $e');
      ModernSnackbar.error(
        title: 'Error',
        message: 'Failed to delete comment: $e',
      );
      return false;
    }
  }

  List<EventComment> get filteredComments {
    if (searchQuery.value.isEmpty) {
      return comments;
    }
    
    return comments.where((comment) {
      final query = searchQuery.value.toLowerCase();
      return comment.content.toLowerCase().contains(query) ||
             comment.user.name.toLowerCase().contains(query);
    }).toList();
  }

  List<EventComment> getCommentsByType(String type) {
    final list = comments.where((comment) => comment.commentType == type).toList();
    // Show oldest first for all types so the latest is at the bottom.
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }
}
