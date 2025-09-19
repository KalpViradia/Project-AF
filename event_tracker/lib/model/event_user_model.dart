import '../utils/import_export.dart';
import 'base_model.dart';

@Deprecated('Use EventInviteModel instead. This class will be removed in a future version.')
class EventUserModel implements BaseModel {
  final String eventId;
  final String userId;
  final bool isAdmin;
  final bool isVerified;
  final String role;
  final InviteStatus status;
  final int noOfAdults;
  final int noOfChildren;
  final String? responseDateTime;
  final String? note;
  final String createdAt;
  final String? updatedAt;

  EventUserModel({
    required this.eventId,
    required this.userId,
    this.isAdmin = false,
    this.isVerified = false,
    this.role = 'invitee',
    String? status,
    this.noOfAdults = 1,
    this.noOfChildren = 0,
    this.responseDateTime,
    this.note,
    required this.createdAt,
    this.updatedAt,
  }) : status = InviteStatusExtension.fromString(status ?? 'pending');

  // Role-based permission checks
  bool get canEditEvent => isAdmin;
  bool get canDeleteEvent => isAdmin;
  bool get canInviteUsers => isAdmin;
  bool get canViewEvent => status == InviteStatus.accepted || isAdmin;
  bool get canManageInvites => isAdmin;
  
  // Status checks
  bool get isPending => status == InviteStatus.pending;
  bool get isAccepted => status == InviteStatus.accepted;
  bool get isDeclined => status == InviteStatus.declined;
  bool get isCancelled => status == InviteStatus.cancelled;

  // Get role display name
  String get roleDisplayName {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'attendee':
        return 'Attendee';
      case 'invitee':
        return 'Invitee';
      default:
        return role;
    }
  }

  // Get role color
  Color get roleColor {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'attendee':
        return Colors.green;
      case 'invitee':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'userId': userId,
    'isAdmin': isAdmin,
    'isVerified': isVerified,
    'role': role,
    'status': status.value,
    'noOfAdults': noOfAdults,
    'noOfChildren': noOfChildren,
    'responseDateTime': responseDateTime,
    'note': note,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  Map<String, dynamic> toMap() => {
    COL_EVENT_ID: eventId,
    COL_USER_ID: userId,
    COL_EU_IS_ADMIN: isAdmin ? 1 : 0,
    COL_EU_IS_VERIFIED: isVerified ? 1 : 0,
    COL_EU_ROLE: role,
    COL_EU_STATUS: status.value,
    COL_EU_NO_OF_ADULTS: noOfAdults,
    COL_EU_NO_OF_CHILDREN: noOfChildren,
    COL_EU_RESPONSE_DATETIME: responseDateTime,
    COL_EU_NOTE: note,
    COL_CREATED_AT: createdAt,
    COL_UPDATED_AT: updatedAt,
  };

  factory EventUserModel.fromMap(Map<String, dynamic> map) => EventUserModel(
    eventId: map[COL_EVENT_ID],
    userId: map[COL_USER_ID],
    isAdmin: map[COL_EU_IS_ADMIN] == 1,
    isVerified: map[COL_EU_IS_VERIFIED] == 1,
    role: map[COL_EU_ROLE] ?? 'invitee',
    status: map[COL_EU_STATUS] ?? 'pending',
    noOfAdults: map[COL_EU_NO_OF_ADULTS] ?? 1,
    noOfChildren: map[COL_EU_NO_OF_CHILDREN] ?? 0,
    responseDateTime: map[COL_EU_RESPONSE_DATETIME],
    note: map[COL_EU_NOTE],
    createdAt: map[COL_CREATED_AT],
    updatedAt: map[COL_UPDATED_AT],
  );

  EventUserModel copyWith({
    String? eventId,
    String? userId,
    bool? isAdmin,
    bool? isVerified,
    String? role,
    InviteStatus? status,
    int? noOfAdults,
    int? noOfChildren,
    String? responseDateTime,
    String? note,
    String? createdAt,
    String? updatedAt,
  }) {
    return EventUserModel(
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      isAdmin: isAdmin ?? this.isAdmin,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      status: status?.value ?? this.status.value,
      noOfAdults: noOfAdults ?? this.noOfAdults,
      noOfChildren: noOfChildren ?? this.noOfChildren,
      responseDateTime: responseDateTime ?? this.responseDateTime,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 