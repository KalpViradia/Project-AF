import '../utils/import_export.dart';

class InviteService {
  final AppDatabase _db = AppDatabase();

  // Search users by phone number
  Future<List<UserModel>> searchUsersByPhone(String phone) async {
    final Database db = await _db.database;
    final maps = await db.query(
      TBL_USERS,
      where: '$COL_USER_PHONE LIKE ?',
      whereArgs: ['%$phone%'],
      orderBy: '$COL_USER_NAME ASC',
    );

    return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
  }

  // Create event invite
  Future<bool> createEventInvite(EventUserModel invite) async {
    final Database db = await _db.database;
    try {
      await db.insert(TBL_EVENT_USERS, invite.toMap());
      return true;
    } catch (e) {
      print('Error creating invite: $e');
      return false;
    }
  }

  // Get invited users for an event
  Future<List<EventUserModel>> getEventInvites(String eventId) async {
    final Database db = await _db.database;
    final maps = await db.query(
      TBL_EVENT_USERS,
      where: '$COL_EVENT_ID = ?',
      whereArgs: [eventId],
      orderBy: '$COL_CREATED_AT DESC',
    );

    return List.generate(maps.length, (i) => EventUserModel.fromMap(maps[i]));
  }

  // Get invites for a user
  Future<List<EventUserModel>> getUserInvites(String userId) async {
    final Database db = await _db.database;
    final maps = await db.query(
      TBL_EVENT_USERS,
      where: '$COL_USER_ID = ?',
      whereArgs: [userId],
      orderBy: '$COL_CREATED_AT DESC',
    );

    return List.generate(maps.length, (i) => EventUserModel.fromMap(maps[i]));
  }

  // Get pending invites for a user
  Future<List<EventUserModel>> getUserPendingInvites(String userId) async {
    final Database db = await _db.database;
    final maps = await db.query(
      TBL_EVENT_USERS,
      where: '$COL_USER_ID = ? AND $COL_EU_STATUS = ?',
      whereArgs: [userId, 'pending'],
      orderBy: '$COL_CREATED_AT DESC',
    );

    return List.generate(maps.length, (i) => EventUserModel.fromMap(maps[i]));
  }

  // Update invite status
  Future<bool> updateInviteStatus(String eventId, String userId, String status, {String? note}) async {
    final Database db = await _db.database;
    final Map<String, dynamic> values = {
      COL_EU_STATUS: status,
      COL_EU_RESPONSE_DATETIME: DateTime.now().toIso8601String(),
      COL_UPDATED_AT: DateTime.now().toIso8601String(),
    };
    
    if (note != null) {
      values[COL_EU_NOTE] = note;
    }

    final rowsAffected = await db.update(
      TBL_EVENT_USERS,
      values,
      where: '$COL_EVENT_ID = ? AND $COL_USER_ID = ?',
      whereArgs: [eventId, userId],
    );

    return rowsAffected > 0;
  }

  // Check if user is invited to event
  Future<bool> isUserInvitedToEvent(String eventId, String userId) async {
    final Database db = await _db.database;
    final result = await db.query(
      TBL_EVENT_USERS,
      where: '$COL_EVENT_ID = ? AND $COL_USER_ID = ?',
      whereArgs: [eventId, userId],
    );
    return result.isNotEmpty;
  }

  // Get invite details
  Future<EventUserModel?> getInviteDetails(String eventId, String userId) async {
    final Database db = await _db.database;
    final result = await db.query(
      TBL_EVENT_USERS,
      where: '$COL_EVENT_ID = ? AND $COL_USER_ID = ?',
      whereArgs: [eventId, userId],
    );
    
    return result.isNotEmpty ? EventUserModel.fromMap(result.first) : null;
  }

  // Delete invite
  Future<bool> deleteInvite(String eventId, String userId) async {
    final Database db = await _db.database;
    final rowsAffected = await db.delete(
      TBL_EVENT_USERS,
      where: '$COL_EVENT_ID = ? AND $COL_USER_ID = ?',
      whereArgs: [eventId, userId],
    );
    return rowsAffected > 0;
  }

  // Get event details with invite information
  Future<Map<String, dynamic>> getEventWithInviteInfo(String eventId, String userId) async {
    final Database db = await _db.database;
    
    // Get event details
    final eventResult = await db.query(
      TBL_EVENTS,
      where: '$COL_EVENT_ID = ?',
      whereArgs: [eventId],
    );
    
    // Get invite details
    final inviteResult = await db.query(
      TBL_EVENT_USERS,
      where: '$COL_EVENT_ID = ? AND $COL_USER_ID = ?',
      whereArgs: [eventId, userId],
    );
    
    return {
      'event': eventResult.isNotEmpty ? Event.fromMap(eventResult.first) : null,
      'invite': inviteResult.isNotEmpty ? EventUserModel.fromMap(inviteResult.first) : null,
    };
  }

  // Get events that user is invited to (for home page display)
  Future<List<Map<String, dynamic>>> getEventsUserIsInvitedTo(String userId) async {
    final Database db = await _db.database;
    
    // Join events and event_users tables - only get accepted invites where user is not the creator
    final maps = await db.rawQuery('''
      SELECT e.*, eu.role, eu.status, eu.is_admin
      FROM $TBL_EVENTS e
      INNER JOIN $TBL_EVENT_USERS eu ON e.$COL_EVENT_ID = eu.$COL_EVENT_ID
      WHERE eu.$COL_USER_ID = ? 
        AND eu.$COL_EU_STATUS = 'accepted'
        AND e.$COL_EVENT_CREATED_BY != ?
      ORDER BY e.$COL_EVENT_START_DATETIME DESC
    ''', [userId, userId]);
    
    return maps.map((map) => {
      'event': Event.fromMap(map),
      'invite': EventUserModel(
        eventId: map[COL_EVENT_ID] as String,
        userId: userId,
        isAdmin: (map[COL_EU_IS_ADMIN] as int?) == 1,
        role: (map[COL_EU_ROLE] as String?) ?? 'invitee',
        status: (map[COL_EU_STATUS] as String?) ?? 'accepted',
        createdAt: map[COL_CREATED_AT] as String,
      ),
    }).toList();
  }

  // Get user's role for a specific event
  Future<EventUserModel?> getUserRoleForEvent(String eventId, String userId) async {
    final Database db = await _db.database;
    final result = await db.query(
      TBL_EVENT_USERS,
      where: '$COL_EVENT_ID = ? AND $COL_USER_ID = ?',
      whereArgs: [eventId, userId],
    );
    
    return result.isNotEmpty ? EventUserModel.fromMap(result.first) : null;
  }
} 