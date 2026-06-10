/// Metadata for an uploaded resume PDF.
class Resume {
  final String id;
  final String name;
  final String fileName;
  final String uploadDate; // ISO date string e.g. "2026-06-10"
  final String? notes;

  const Resume({
    required this.id,
    required this.name,
    required this.fileName,
    required this.uploadDate,
    this.notes,
  });

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      uploadDate: json['uploadDate'] as String? ?? '',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fileName': fileName,
        'uploadDate': uploadDate,
        'notes': notes,
      };

  Resume copyWith({
    String? id,
    String? name,
    String? fileName,
    String? uploadDate,
    String? notes,
  }) {
    return Resume(
      id: id ?? this.id,
      name: name ?? this.name,
      fileName: fileName ?? this.fileName,
      uploadDate: uploadDate ?? this.uploadDate,
      notes: notes ?? this.notes,
    );
  }
}
