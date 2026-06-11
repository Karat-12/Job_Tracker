/// A first-class recruitment event stored in the application_events collection.
///
/// Independent from the embedded [TimelineEvent] list inside [Application].
/// Sorted by [eventDate] (ascending) when displayed.
class ApplicationEvent {
  final String id;
  final String applicationId;
  final String eventType;

  /// ISO date string "YYYY-MM-DD" — may be a future date for scheduled events.
  final String eventDate;

  final String? notes;

  /// ISO-8601 datetime string set server-side at creation. Never sent by client.
  final String createdAt;

  const ApplicationEvent({
    required this.id,
    required this.applicationId,
    required this.eventType,
    required this.eventDate,
    this.notes,
    required this.createdAt,
  });

  factory ApplicationEvent.fromJson(Map<String, dynamic> json) {
    return ApplicationEvent(
      id: json['id'] as String? ?? '',
      applicationId: json['applicationId'] as String? ?? '',
      eventType: json['eventType'] as String? ?? '',
      eventDate: json['eventDate'] as String? ?? '',
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'applicationId': applicationId,
        'eventType': eventType,
        'eventDate': eventDate,
        'notes': notes,
        'createdAt': createdAt,
      };

  ApplicationEvent copyWith({
    String? id,
    String? applicationId,
    String? eventType,
    String? eventDate,
    String? notes,
    String? createdAt,
  }) {
    return ApplicationEvent(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Parses [eventDate] ("YYYY-MM-DD") into a [DateTime].
  /// Returns null if the string is empty or malformed.
  DateTime? get eventDateTime {
    if (eventDate.isEmpty) return null;
    try {
      return DateTime.parse(eventDate);
    } catch (_) {
      return null;
    }
  }
}
