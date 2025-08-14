import '../utils/import_export.dart';

class EventInviteModel {
  final String inviteId;
  final String eventId;
  final String phone;
  final String status;
  final String invitedAt;
  final String? respondedAt;

  EventInviteModel({
    required this.inviteId,
    required this.eventId,
    required this.phone,
    this.status = 'pending',
    required this.invitedAt,
    this.respondedAt,
  });

  Map<String, dynamic> toMap() => {
    COL_INVITE_ID: inviteId,
    COL_INVITE_EVENT_ID: eventId,
    COL_INVITE_PHONE: phone,
    COL_INVITE_STATUS: status,
    COL_INVITE_INVITED_AT: invitedAt,
    COL_INVITE_RESPONDED_AT: respondedAt,
  };

  factory EventInviteModel.fromMap(Map<String, dynamic> map) => EventInviteModel(
    inviteId: map[COL_INVITE_ID],
    eventId: map[COL_INVITE_EVENT_ID],
    phone: map[COL_INVITE_PHONE],
    status: map[COL_INVITE_STATUS] ?? 'pending',
    invitedAt: map[COL_INVITE_INVITED_AT],
    respondedAt: map[COL_INVITE_RESPONDED_AT],
  );
}
