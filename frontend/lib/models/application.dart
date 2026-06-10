import 'timeline_event.dart';

class Application {
  final String id;
  final String companyName;
  final String role;
  final String source;
  final String jobLink;
  final DateTime dateApplied;
  final String status;
  final String? notes;

  /// ID of the linked Resume document. Null when no resume is linked.
  final String? resumeId;

  /// Full ordered history of status transitions. Never null — defaults to [].
  final List<TimelineEvent> timeline;

  Application({
    required this.id,
    required this.companyName,
    required this.role,
    required this.source,
    required this.jobLink,
    required this.dateApplied,
    required this.status,
    this.notes,
    this.resumeId,
    List<TimelineEvent>? timeline,
  }) : timeline = timeline ?? [];

  factory Application.fromJson(Map<String, dynamic> json) {
    final rawTimeline = json['timeline'];
    final List<TimelineEvent> timeline = rawTimeline is List
        ? rawTimeline
              .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList()
        : [];

    return Application(
      id: json['id'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      source: json['source'] as String? ?? '',
      jobLink: json['jobLink'] as String? ?? '',
      dateApplied: DateTime.parse(json['dateApplied'] as String),
      status: json['status'] as String? ?? '',
      notes: json['notes'] as String?,
      resumeId: json['resumeId'] as String?,
      timeline: timeline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'role': role,
      'source': source,
      'jobLink': jobLink,
      'dateApplied': dateApplied.toIso8601String().split('T').first,
      'status': status,
      'notes': notes,
      'resumeId': resumeId,
      // Timeline is managed server-side; still serialised so the field
      // round-trips correctly, but the server ignores it on update.
      'timeline': timeline.map((e) => e.toJson()).toList(),
    };
  }

  Application copyWith({
    String? id,
    String? companyName,
    String? role,
    String? source,
    String? jobLink,
    DateTime? dateApplied,
    String? status,
    String? notes,
    String? resumeId,
    List<TimelineEvent>? timeline,
  }) {
    return Application(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      role: role ?? this.role,
      source: source ?? this.source,
      jobLink: jobLink ?? this.jobLink,
      dateApplied: dateApplied ?? this.dateApplied,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      resumeId: resumeId ?? this.resumeId,
      timeline: timeline ?? this.timeline,
    );
  }
}
