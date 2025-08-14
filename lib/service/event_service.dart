import '../utils/import_export.dart';

class EventService {
  final AppDatabase _db = AppDatabase();

  // Create Event
  Future<Event> createEvent(Event event) async {
    final Database db = await _db.database;
    await db.insert(TBL_EVENTS, event.toMap());
    return event;
  }

  // Read Events (with optional search)
  Future<List<Event>> getEvents({String? userId, String? searchQuery}) async {
    final Database db = await _db.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause += '$COL_EVENT_CREATED_BY = ?';
      whereArgs.add(userId);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += '$COL_EVENT_TITLE LIKE ?';
      whereArgs.add('%$searchQuery%');
    }

    final maps = await db.query(
      TBL_EVENTS,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: '$COL_EVENT_START_DATETIME DESC',
    );

    return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
  }

  // Get Single Event
  Future<Event?> getEventById(String eventId) async {
    final Database db = await _db.database;
    final results = await db.query(
      TBL_EVENTS,
      where: '$COL_EVENT_ID = ?',
      whereArgs: [eventId],
    );
    return results.isNotEmpty ? Event.fromMap(results.first) : null;
  }

  // Update Event
  Future<bool> updateEvent(Event event) async {
    final Database db = await _db.database;
    final Map<String, dynamic> values = event.toMap();
    values[COL_UPDATED_AT] = DateTime.now().toIso8601String();

    final rowsAffected = await db.update(
      TBL_EVENTS,
      values,
      where: '$COL_EVENT_ID = ?',
      whereArgs: [event.id],
    );

    return rowsAffected > 0;
  }

  // Toggle Event Visibility
  Future<bool> toggleEventVisibility(String id, bool isVisible) async {
    final Database db = await _db.database;
    final rowsAffected = await db.update(
      TBL_EVENTS,
      {
        COL_EVENT_IS_VISIBLE: isVisible ? 1 : 0,
        COL_UPDATED_AT: DateTime.now().toIso8601String(),
      },
      where: '$COL_EVENT_ID = ?',
      whereArgs: [id],
    );
    return rowsAffected > 0;
  }

  // Get Invisible Events
  Future<List<Event>> getInvisibleEvents({String? userId}) async {
    final Database db = await _db.database;
    String whereClause = '$COL_EVENT_IS_VISIBLE = 0';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause += ' AND $COL_EVENT_CREATED_BY = ?';
      whereArgs.add(userId);
    }

    final maps = await db.query(
      TBL_EVENTS,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '$COL_EVENT_START_DATETIME DESC',
    );

    return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
  }
}
