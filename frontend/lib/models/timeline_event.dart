/// A single event in an application's status history.
class TimelineEvent {
  final String title;
  final String description;
  final String timestamp; // ISO-8601 e.g. "2026-06-10T14:30:00"

  const TimelineEvent({
    required this.title,
    required this.description,
    required this.timestamp,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'timestamp': timestamp,
      };

  /// Parses the timestamp into a [DateTime]. Returns null on parse failure.
  DateTime? get dateTime {
    try {
      return DateTime.parse(timestamp);
    } catch (_) {
      return null;
    }
  }
}
