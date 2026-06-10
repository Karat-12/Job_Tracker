class Application {
  final String id;
  final String companyName;
  final String role;
  final String source;
  final String jobLink;
  final DateTime dateApplied;
  final String status;
  final String? notes;

  Application({
    required this.id,
    required this.companyName,
    required this.role,
    required this.source,
    required this.jobLink,
    required this.dateApplied,
    required this.status,
    this.notes,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] ?? '',
      companyName: json['companyName'] ?? '',
      role: json['role'] ?? '',
      source: json['source'] ?? '',
      jobLink: json['jobLink'] ?? '',
      dateApplied: DateTime.parse(json['dateApplied']),
      status: json['status'] ?? '',
      notes: json['notes'],
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
    );
  }
}
