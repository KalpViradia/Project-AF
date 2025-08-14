import '../utils/import_export.dart';

class EventInviteService {
  final AppDatabase _db = AppDatabase();

  // Create Event Invite
  Future<EventInviteModel> createEventInvite(EventInviteModel invite) async {
    final Database db = await _db.database;
    await db.insert(TBL_EVENT_INVITES, invite.toMap());
    return invite;
  }

  // Get Event Invites by Event ID
  Future<List<EventInviteModel>> getEventInvitesByEventId(String eventId) async {
    final Database db = await _db.database;
    final maps = await db.query(
      TBL_EVENT_INVITES,
      where: '$COL_INVITE_EVENT_ID = ?',
      whereArgs: [eventId],
      orderBy: '$COL_INVITE_INVITED_AT DESC',
    );

    return List.generate(maps.length, (i) => EventInviteModel.fromMap(maps[i]));
  }

  // Get Event Invites by Phone Number
  Future<List<EventInviteModel>> getEventInvitesByPhone(String phone) async {
    final Database db = await _db.database;
    final maps = await db.query(
      TBL_EVENT_INVITES,
      where: '$COL_INVITE_PHONE = ?',
      whereArgs: [phone],
      orderBy: '$COL_INVITE_INVITED_AT DESC',
    );

    return List.generate(maps.length, (i) => EventInviteModel.fromMap(maps[i]));
  }

  // Get Pending Event Invites by Phone Number
  Future<List<EventInviteModel>> getPendingEventInvitesByPhone(String phone) async {
    final Database db = await _db.database;
    final maps = await db.query(
      TBL_EVENT_INVITES,
      where: '$COL_INVITE_PHONE = ? AND $COL_INVITE_STATUS = ?',
      whereArgs: [phone, 'pending'],
      orderBy: '$COL_INVITE_INVITED_AT DESC',
    );

    return List.generate(maps.length, (i) => EventInviteModel.fromMap(maps[i]));
  }

  // Update Event Invite Status
  Future<bool> updateEventInviteStatus(String inviteId, String status) async {
    final Database db = await _db.database;
    final Map<String, dynamic> values = {
      COL_INVITE_STATUS: status,
      COL_INVITE_RESPONDED_AT: DateTime.now().toIso8601String(),
    };

    final rowsAffected = await db.update(
      TBL_EVENT_INVITES,
      values,
      where: '$COL_INVITE_ID = ?',
      whereArgs: [inviteId],
    );

    return rowsAffected > 0;
  }

  // Delete Event Invite
  Future<bool> deleteEventInvite(String inviteId) async {
    final Database db = await _db.database;
    final rowsAffected = await db.delete(
      TBL_EVENT_INVITES,
      where: '$COL_INVITE_ID = ?',
      whereArgs: [inviteId],
    );
    return rowsAffected > 0;
  }

  // Check if user is invited to event
  Future<bool> isUserInvitedToEvent(String eventId, String phone) async {
    final Database db = await _db.database;
    final result = await db.query(
      TBL_EVENT_INVITES,
      where: '$COL_INVITE_EVENT_ID = ? AND $COL_INVITE_PHONE = ?',
      whereArgs: [eventId, phone],
    );
    return result.isNotEmpty;
  }

  // Get Event Invite by ID
  Future<EventInviteModel?> getEventInviteById(String inviteId) async {
    final Database db = await _db.database;
    final results = await db.query(
      TBL_EVENT_INVITES,
      where: '$COL_INVITE_ID = ?',
      whereArgs: [inviteId],
    );
    return results.isNotEmpty ? EventInviteModel.fromMap(results.first) : null;
  }
}
