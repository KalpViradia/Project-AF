import '../utils/import_export.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String? address;
  final int? categoryId;
  final String? eventType;
  final int? maxCapacity;
  final bool isCancelled;
  final bool isCompleted;
  final bool isVisible;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Recurring event properties
  final bool isRecurring;
  final String? recurrenceType;
  final int recurrenceInterval;
  final DateTime? recurrenceEndDate;
  final String? parentEventId;

  Event({
    String? id,
    required this.title,
    required this.description,
    required this.startDateTime,
    this.endDateTime,
    this.address,
    this.categoryId,
    this.eventType,
    this.maxCapacity,
    this.isCancelled = false,
    this.isCompleted = false,
    this.isVisible = true,
    required this.createdBy,
    DateTime? createdAt,
    this.updatedAt,
    this.isRecurring = false,
    this.recurrenceType,
    this.recurrenceInterval = 1,
    this.recurrenceEndDate,
    this.parentEventId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime?.toIso8601String(),
      'address': address,
      'categoryId': categoryId,
      'eventType': eventType,
      'maxCapacity': maxCapacity,
      'isCancelled': isCancelled,
      'isCompleted': isCompleted,
      'isVisible': isVisible,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType,
      'recurrenceInterval': recurrenceInterval,
      'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
      'parentEventId': parentEventId,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      return Event(
        id: (json['id'] ?? json['Id'])?.toString() ?? '',
        title: (json['title'] ?? json['Title'])?.toString() ?? '',
        description: (json['description'] ?? json['Description'])?.toString() ?? '',
        startDateTime: (json['startDateTime'] ?? json['StartDateTime']) != null 
            ? DateTime.parse((json['startDateTime'] ?? json['StartDateTime']).toString())
            : DateTime.now(),
        endDateTime: (json['endDateTime'] ?? json['EndDateTime']) != null
            ? DateTime.parse((json['endDateTime'] ?? json['EndDateTime']).toString())
            : null,
        address: (json['address'] ?? json['Address'])?.toString(),
        categoryId: (json['categoryId'] ?? json['CategoryId']) != null ? int.tryParse((json['categoryId'] ?? json['CategoryId']).toString()) : null,
        eventType: (json['eventType'] ?? json['EventType'])?.toString(),
        maxCapacity: (json['maxCapacity'] ?? json['MaxCapacity']) != null ? int.tryParse((json['maxCapacity'] ?? json['MaxCapacity']).toString()) : null,
        isCancelled: (json['isCancelled'] ?? json['IsCancelled']) == true || (json['isCancelled'] ?? json['IsCancelled']) == 1,
        isCompleted: (json['isCompleted'] ?? json['IsCompleted']) == true || (json['isCompleted'] ?? json['IsCompleted']) == 1,
        isVisible: (json['isVisible'] ?? json['IsVisible']) == true || (json['isVisible'] ?? json['IsVisible']) == 1,
        createdBy: (json['createdBy'] ?? json['CreatedBy'])?.toString() ?? '',
        createdAt: (json['createdAt'] ?? json['CreatedAt']) != null 
            ? DateTime.parse((json['createdAt'] ?? json['CreatedAt']).toString())
            : DateTime.now(),
        updatedAt: (json['updatedAt'] ?? json['UpdatedAt']) != null
            ? DateTime.parse((json['updatedAt'] ?? json['UpdatedAt']).toString())
            : null,
        isRecurring: (json['isRecurring'] ?? json['IsRecurring']) == true || (json['isRecurring'] ?? json['IsRecurring']) == 1,
        recurrenceType: (json['recurrenceType'] ?? json['RecurrenceType'])?.toString(),
        recurrenceInterval: (json['recurrenceInterval'] ?? json['RecurrenceInterval']) != null ? int.tryParse((json['recurrenceInterval'] ?? json['RecurrenceInterval']).toString()) ?? 1 : 1,
        recurrenceEndDate: (json['recurrenceEndDate'] ?? json['RecurrenceEndDate']) != null
            ? DateTime.parse((json['recurrenceEndDate'] ?? json['RecurrenceEndDate']).toString())
            : null,
        parentEventId: (json['parentEventId'] ?? json['ParentEventId'])?.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? address,
    int? categoryId,
    String? eventType,
    int? maxCapacity,
    bool? isCancelled,
    bool? isCompleted,
    bool? isVisible,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRecurring,
    String? recurrenceType,
    int? recurrenceInterval,
    DateTime? recurrenceEndDate,
    String? parentEventId,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      address: address ?? this.address,
      categoryId: categoryId ?? this.categoryId,
      eventType: eventType ?? this.eventType,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      isCancelled: isCancelled ?? this.isCancelled,
      isCompleted: isCompleted ?? this.isCompleted,
      isVisible: isVisible ?? this.isVisible,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      parentEventId: parentEventId ?? this.parentEventId,
    );
  }

  // Helper methods for participant management
  int getTotalAcceptedParticipants(List<EventInviteModel> invites) {
    return invites
        .where((invite) => invite.eventId == id && invite.isAccepted)
        .fold(0, (sum, invite) => sum + invite.participantCount);
  }

  int getAvailableSpaces(List<EventInviteModel> invites) {
    final totalAccepted = getTotalAcceptedParticipants(invites);
    return maxCapacity != null ? (maxCapacity! - totalAccepted).clamp(0, maxCapacity!) : 999;
  }

  bool hasAvailableSpace(List<EventInviteModel> invites, int requestedParticipants) {
    if (maxCapacity == null) return true;
    return getAvailableSpaces(invites) >= requestedParticipants;
  }

  String getCapacityDisplayText(List<EventInviteModel> invites) {
    if (maxCapacity == null) return 'Unlimited capacity';
    final totalAccepted = getTotalAcceptedParticipants(invites);
    final available = getAvailableSpaces(invites);
    return '$totalAccepted/$maxCapacity participants • $available spaces available';
  }
}
