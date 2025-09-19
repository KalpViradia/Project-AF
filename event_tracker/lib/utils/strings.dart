//region Table Names
const String TBL_USERS = 'users';
const String TBL_EVENTS = 'events';
const String TBL_EVENT_TYPES = 'event_types';
const String TBL_EVENT_USERS = 'event_users';
const String TBL_EVENT_INVITES = 'event_invites';
//endregion

//region Common Columns
const String COL_CREATED_AT = 'created_at';
const String COL_UPDATED_AT = 'updated_at';
//endregion

//region Users Table
const String COL_USER_ID = 'user_id';
const String COL_USER_NAME = 'name';
const String COL_USER_EMAIL = 'email';
const String COL_USER_PASSWORD = 'password';
const String COL_USER_PHONE = 'phone';
const String COL_USER_DOB = 'date_of_birth';
const String COL_USER_GENDER = 'gender';
const String COL_USER_ROLE = 'role';
const String COL_USER_BIO = 'bio';
const String COL_USER_EMAIL_VERIFIED = 'email_verified';
const String COL_USER_IS_ACTIVE = 'is_active';
const String COL_EVENT_IS_ALL_DAY = 'is_all_day';
const String COL_EVENT_LOCATION = 'location';
const String COL_USER_LAST_LOGIN = 'last_login';
//endregion

//region Events Table
const String COL_EVENT_ID = 'event_id';
const String COL_EVENT_TITLE = 'title';
const String COL_EVENT_DESCRIPTION = 'description';
const String COL_EVENT_START_DATETIME = 'start_datetime';
const String COL_EVENT_END_DATETIME = 'end_datetime';
const String COL_EVENT_LATITUDE = 'latitude';
const String COL_EVENT_LONGITUDE = 'longitude';
const String COL_EVENT_ADDRESS = 'address';
const String COL_EVENT_CATEGORY_ID = 'category_id';
const String COL_EVENT_TYPE = 'event_type';
const String COL_EVENT_MAX_CAPACITY = 'max_capacity';
const String COL_EVENT_IS_CANCELLED = 'is_cancelled';
const String COL_EVENT_IS_COMPLETED = 'is_completed';
const String COL_EVENT_IS_REMINDER_SET = 'is_reminder_set';
const String COL_EVENT_REMINDER_DATETIME = 'reminder_datetime';
const String COL_EVENT_IS_VISIBLE = 'is_visible';
const String COL_EVENT_CREATED_BY = 'created_by';
//endregion

//region Event Types Table
const String COL_EVENT_TYPE_ID = 'category_id';
const String COL_EVENT_TYPE_NAME = 'name';
const String COL_EVENT_TYPE_ICON_NAME = 'icon_name';
const String COL_EVENT_TYPE_COLOR_CODE = 'color_code';
//endregion

//region Event Users Table
const String COL_EU_IS_ADMIN = 'is_admin';
const String COL_EU_IS_VERIFIED = 'is_verified';
const String COL_EU_ROLE = 'role';
const String COL_EU_STATUS = 'status';
const String COL_EU_NO_OF_ADULTS = 'no_of_adults';
const String COL_EU_NO_OF_CHILDREN = 'no_of_children';
const String COL_EU_RESPONSE_DATETIME = 'response_datetime';
const String COL_EU_NOTE = 'note';
//endregion

//region Event Invites Table
const String COL_INVITE_ID = 'invite_id';
const String COL_INVITE_EVENT_ID = 'event_id';
const String COL_INVITE_PHONE = 'phone';
const String COL_INVITE_STATUS = 'status';
const String COL_INVITE_INVITED_AT = 'invited_at';
const String COL_INVITE_RESPONDED_AT = 'responded_at';
//endregion
