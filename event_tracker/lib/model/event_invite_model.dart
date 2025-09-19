import '../utils/import_export.dart';
import 'base_model.dart';

class EventInviteModel implements BaseModel {
  final String id;
  final String eventId;
  final String invitedUserId;
  final UserModel? invitedUser;
  final Event? event;
  final InviteStatus status;
  final int participantCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EventInviteModel({
    String? id,
    required this.eventId,
    required this.invitedUserId,
    this.invitedUser,
    this.event,
    this.status = InviteStatus.pending,
    this.participantCount = 1,
    DateTime? createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventId': eventId,
    'invitedUserId': invitedUserId,
    'status': status.toString().split('.').last,
    'participantCount': participantCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory EventInviteModel.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing EventInviteModel JSON: $json');
      
      return EventInviteModel(
        id: (json['id'] ?? json['Id'])?.toString() ?? '',
        eventId: (json['eventId'] ?? json['EventId'])?.toString() ?? '',
        invitedUserId: (json['invitedUserId'] ?? json['InvitedUserId'])?.toString() ?? '',
        invitedUser: (json['invitedUser'] ?? json['InvitedUser']) != null 
            ? UserModel.fromJson(Map<String, dynamic>.from(json['invitedUser'] ?? json['InvitedUser'])) 
            : null,
        event: (json['event'] ?? json['Event']) != null 
            ? Event.fromJson(Map<String, dynamic>.from(json['event'] ?? json['Event'])) 
            : null,
        status: InviteStatusExtension.fromString(((json['status'] ?? json['Status']) ?? 'pending').toString().toLowerCase()),
        participantCount: int.tryParse((json['participantCount'] ?? json['ParticipantCount'])?.toString() ?? '1') ?? 1,
        createdAt: (json['createdAt'] ?? json['CreatedAt']) != null 
            ? DateTime.parse((json['createdAt'] ?? json['CreatedAt']).toString())
            : DateTime.now(),
        updatedAt: (json['updatedAt'] ?? json['UpdatedAt']) != null 
            ? DateTime.parse((json['updatedAt'] ?? json['UpdatedAt']).toString()) 
            : null,
      );
    } catch (e) {
      print('Error parsing EventInviteModel from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Helper getters for checking status
  bool get isPending => status == InviteStatus.pending;
  bool get isAccepted => status == InviteStatus.accepted;
  bool get isDeclined => status == InviteStatus.declined;
  bool get isCancelled => status == InviteStatus.cancelled;

  // Get status color
  Color get statusColor {
    switch (status) {
      case InviteStatus.pending:
        return Colors.orange;
      case InviteStatus.accepted:
        return Colors.green;
      case InviteStatus.declined:
        return Colors.red;
      case InviteStatus.cancelled:
        return Colors.grey;
    }
  }

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case InviteStatus.pending:
        return 'Pending';
      case InviteStatus.accepted:
        return 'Accepted';
      case InviteStatus.declined:
        return 'Declined';
      case InviteStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  // Copy method
  EventInviteModel copyWith({
    String? id,
    String? eventId,
    String? invitedUserId,
    UserModel? invitedUser,
    Event? event,
    InviteStatus? status,
    int? participantCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EventInviteModel(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    invitedUserId: invitedUserId ?? this.invitedUserId,
    invitedUser: invitedUser ?? this.invitedUser,
    event: event ?? this.event,
    status: status ?? this.status,
    participantCount: participantCount ?? this.participantCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  String toString() => toJson().toString();
}
