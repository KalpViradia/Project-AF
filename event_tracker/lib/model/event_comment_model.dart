import 'user/user_model.dart';

class EventComment {
  final String id;
  final String eventId;
  final String userId;
  final String content;
  final String commentType; // "comment" or "announcement"
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserModel user;

  EventComment({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.content,
    required this.commentType,
    required this.createdAt,
    this.updatedAt,
    required this.user,
  });

  factory EventComment.fromJson(Map<String, dynamic> json) {
    return EventComment(
      id: json['id'] ?? json['Id'] ?? '',
      eventId: json['eventId'] ?? json['EventId'] ?? '',
      userId: json['userId'] ?? json['UserId'] ?? '',
      content: json['content'] ?? json['Content'] ?? '',
      commentType: json['commentType'] ?? json['CommentType'] ?? 'comment',
      createdAt: _parseApiDateTime(json['createdAt'] ?? json['CreatedAt']),
      updatedAt: _parseApiDateTimeNullable(json['updatedAt'] ?? json['UpdatedAt']),
      user: UserModel.fromJson(json['user'] ?? json['User'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'content': content,
      'commentType': commentType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'user': user.toJson(),
    };
  }
}

class EventCommentCreateRequest {
  final String eventId;
  final String content;
  final String commentType;
  final String? userId; // Optional: supply when JWT not available

  EventCommentCreateRequest({
    required this.eventId,
    required this.content,
    this.commentType = 'comment',
    this.userId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'eventId': eventId,
      'content': content,
      'commentType': commentType,
    };
    if (userId != null && userId!.isNotEmpty) {
      map['userId'] = userId;
    }
    return map;
  }
}

class EventCommentUpdateRequest {
  final String content;

  EventCommentUpdateRequest({required this.content});

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}

// Helpers to robustly parse API timestamps
DateTime _parseApiDateTime(dynamic value) {
  final raw = value?.toString() ?? '';
  if (raw.isEmpty) return DateTime.now();

  // If the string lacks timezone info, assume UTC by appending 'Z'.
  final hasTimezone = RegExp(r'(Z|[+-]\d{2}:\d{2})$').hasMatch(raw);
  final normalized = hasTimezone ? raw : '${raw}Z';
  try {
    return DateTime.parse(normalized).toLocal();
  } catch (_) {
    // Fallback: try raw parse
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }
}

DateTime? _parseApiDateTimeNullable(dynamic value) {
  if (value == null) return null;
  return _parseApiDateTime(value);
}
