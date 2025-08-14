import '../utils/import_export.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final double? latitude;
  final double? longitude;
  final String? address;
  final int? categoryId;
  final String? eventType;
  final String? coverImageUrl;
  final int? maxCapacity;
  final bool isCancelled;
  final bool isCompleted;
  final bool isVisible;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Event({
    String? id,
    required this.title,
    required this.description,
    required this.startDateTime,
    this.endDateTime,
    this.latitude,
    this.longitude,
    this.address,
    this.categoryId,
    this.eventType,
    this.coverImageUrl,
    this.maxCapacity,
    this.isCancelled = false,
    this.isCompleted = false,
    this.isVisible = true,
    required this.createdBy,
    DateTime? createdAt,
    this.updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      COL_EVENT_ID: id,
      COL_EVENT_TITLE: title,
      COL_EVENT_DESCRIPTION: description,
      COL_EVENT_START_DATETIME: startDateTime.toIso8601String(),
      COL_EVENT_END_DATETIME: endDateTime?.toIso8601String(),
      COL_EVENT_LATITUDE: latitude,
      COL_EVENT_LONGITUDE: longitude,
      COL_EVENT_ADDRESS: address,
      COL_EVENT_CATEGORY_ID: categoryId,
      COL_EVENT_TYPE: eventType,
      COL_EVENT_COVER_IMAGE_URL: coverImageUrl,
      COL_EVENT_MAX_CAPACITY: maxCapacity,
      COL_EVENT_IS_CANCELLED: isCancelled ? 1 : 0,
      COL_EVENT_IS_COMPLETED: isCompleted ? 1 : 0,
      COL_EVENT_IS_VISIBLE: isVisible ? 1 : 0,
      COL_EVENT_CREATED_BY: createdBy,
      COL_CREATED_AT: createdAt.toIso8601String(),
      COL_UPDATED_AT: updatedAt?.toIso8601String(),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map[COL_EVENT_ID],
      title: map[COL_EVENT_TITLE],
      description: map[COL_EVENT_DESCRIPTION] ?? '',
      startDateTime: DateTime.parse(map[COL_EVENT_START_DATETIME]),
      endDateTime: map[COL_EVENT_END_DATETIME] != null
          ? DateTime.parse(map[COL_EVENT_END_DATETIME])
          : null,
      latitude: map[COL_EVENT_LATITUDE],
      longitude: map[COL_EVENT_LONGITUDE],
      address: map[COL_EVENT_ADDRESS],
      categoryId: map[COL_EVENT_CATEGORY_ID],
      eventType: map[COL_EVENT_TYPE],
      coverImageUrl: map[COL_EVENT_COVER_IMAGE_URL],
      maxCapacity: map[COL_EVENT_MAX_CAPACITY],
      isCancelled: map[COL_EVENT_IS_CANCELLED] == 1,
      isCompleted: map[COL_EVENT_IS_COMPLETED] == 1,
      isVisible: map[COL_EVENT_IS_VISIBLE] == 1,
      createdBy: map[COL_EVENT_CREATED_BY],
      createdAt: DateTime.parse(map[COL_CREATED_AT]),
      updatedAt: map[COL_UPDATED_AT] != null
          ? DateTime.parse(map[COL_UPDATED_AT])
          : null,
    );
  }
}
