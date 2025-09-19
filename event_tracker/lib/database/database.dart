import '../utils/import_export.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  factory AppDatabase() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'event_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    //region Create users table
    await db.execute('''
      CREATE TABLE $TBL_USERS (
        $COL_USER_ID TEXT PRIMARY KEY,
        $COL_USER_NAME TEXT NOT NULL,
        $COL_USER_EMAIL TEXT UNIQUE,
        $COL_USER_PASSWORD TEXT NOT NULL,
        $COL_USER_PHONE TEXT NOT NULL UNIQUE,
        $COL_USER_DOB TEXT,
        $COL_USER_GENDER TEXT,
        $COL_USER_ROLE TEXT DEFAULT 'user',
        $COL_USER_BIO TEXT,
        $COL_USER_EMAIL_VERIFIED INTEGER DEFAULT 0,
        $COL_USER_IS_ACTIVE INTEGER DEFAULT 1,
        $COL_USER_LAST_LOGIN TEXT,
        $COL_CREATED_AT TEXT NOT NULL,
        $COL_UPDATED_AT TEXT
      )
    ''');
    //endregion

    //region Create event_types table
    await db.execute('''
      CREATE TABLE $TBL_EVENT_TYPES (
        $COL_EVENT_TYPE_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $COL_EVENT_TYPE_NAME TEXT NOT NULL UNIQUE,
        $COL_EVENT_TYPE_ICON_NAME TEXT,
        $COL_EVENT_TYPE_COLOR_CODE TEXT
      )
    ''');
    //endregion

    //region Create events table
    await db.execute('''
      CREATE TABLE $TBL_EVENTS (
        $COL_EVENT_ID TEXT PRIMARY KEY,
        $COL_EVENT_TITLE TEXT NOT NULL,
        $COL_EVENT_DESCRIPTION TEXT,
        $COL_EVENT_START_DATETIME TEXT NOT NULL,
        $COL_EVENT_END_DATETIME TEXT,
        $COL_EVENT_LATITUDE REAL,
        $COL_EVENT_LONGITUDE REAL,
        $COL_EVENT_ADDRESS TEXT,
        $COL_EVENT_CATEGORY_ID INTEGER,
        $COL_EVENT_TYPE TEXT,
        $COL_EVENT_MAX_CAPACITY INTEGER,
        $COL_EVENT_IS_CANCELLED INTEGER DEFAULT 0,
        $COL_EVENT_IS_COMPLETED INTEGER DEFAULT 0,
        $COL_EVENT_IS_REMINDER_SET INTEGER DEFAULT 0,
        $COL_EVENT_REMINDER_DATETIME TEXT,
        $COL_EVENT_IS_VISIBLE INTEGER DEFAULT 1,
        $COL_EVENT_CREATED_BY TEXT NOT NULL,
        $COL_CREATED_AT TEXT NOT NULL,
        $COL_UPDATED_AT TEXT,
        FOREIGN KEY ($COL_EVENT_CATEGORY_ID) REFERENCES $TBL_EVENT_TYPES($COL_EVENT_TYPE_ID),
        FOREIGN KEY ($COL_EVENT_CREATED_BY) REFERENCES $TBL_USERS($COL_USER_ID)
      )
    ''');
    //endregion

    //region Create event_users table
    await db.execute('''
      CREATE TABLE $TBL_EVENT_USERS (
        $COL_EVENT_ID TEXT,
        $COL_USER_ID TEXT,
        $COL_EU_IS_ADMIN INTEGER DEFAULT 0,
        $COL_EU_IS_VERIFIED INTEGER DEFAULT 0,
        $COL_EU_ROLE TEXT DEFAULT 'invitee',
        $COL_EU_STATUS TEXT DEFAULT 'pending',
        $COL_EU_NO_OF_ADULTS INTEGER DEFAULT 1,
        $COL_EU_NO_OF_CHILDREN INTEGER DEFAULT 0,
        $COL_EU_RESPONSE_DATETIME TEXT,
        $COL_EU_NOTE TEXT,
        $COL_CREATED_AT TEXT NOT NULL,
        $COL_UPDATED_AT TEXT,
        PRIMARY KEY ($COL_EVENT_ID, $COL_USER_ID),
        FOREIGN KEY ($COL_EVENT_ID) REFERENCES $TBL_EVENTS($COL_EVENT_ID) ON DELETE CASCADE,
        FOREIGN KEY ($COL_USER_ID) REFERENCES $TBL_USERS($COL_USER_ID) ON DELETE CASCADE
      )
    ''');
    //endregion

    //region Create event_invites table (for phone-based invitations)
    await db.execute('''
      CREATE TABLE $TBL_EVENT_INVITES (
        $COL_INVITE_ID TEXT PRIMARY KEY,
        $COL_INVITE_EVENT_ID TEXT NOT NULL,
        $COL_INVITE_PHONE TEXT NOT NULL,
        $COL_INVITE_STATUS TEXT DEFAULT 'pending',
        $COL_INVITE_INVITED_AT TEXT NOT NULL,
        $COL_INVITE_RESPONDED_AT TEXT,
        FOREIGN KEY ($COL_INVITE_EVENT_ID) REFERENCES $TBL_EVENTS($COL_EVENT_ID) ON DELETE CASCADE
      )
    ''');
    //endregion
  }
}
