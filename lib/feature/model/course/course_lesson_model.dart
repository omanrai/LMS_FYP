class CourseLessonModel {
  final String id;
  final String title;
  final String description;
  final String? pdfUrl;
  final int readingDuration;
  final String courseId;
  final List<String> keywords;
  final List<dynamic> tests; // You can create a Test model if needed
  final int version;

  CourseLessonModel({
    required this.id,
    required this.title,
    required this.description,
    this.pdfUrl,
    required this.readingDuration,
    required this.courseId,
    required this.keywords,
    required this.tests,
    required this.version,
  });

  factory CourseLessonModel.fromJson(Map<String, dynamic> json) {
    // Handle keywords parsing with null safety
    List<String> parsedKeywords = [];
    if (json['keywords'] != null && json['keywords'] is List) {
      parsedKeywords = (json['keywords'] as List)
          .where((keyword) => keyword != null)
          .map((keyword) => keyword.toString())
          .toList();
    }

    // Handle tests parsing with null safety
    List<dynamic> parsedTests = [];
    if (json['tests'] != null && json['tests'] is List) {
      parsedTests = List<dynamic>.from(json['tests']);
    }

    return CourseLessonModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pdfUrl: json['pdfUrl'],
      readingDuration: json['readingDuration'] ?? 0,
      courseId: json['course'] ?? '',
      keywords: parsedKeywords,
      tests: parsedTests,
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'pdfUrl': pdfUrl,
      'readingDuration': readingDuration,
      'course': courseId,
      'keywords': keywords,
      'tests': tests,
      '__v': version,
    };
  }

  CourseLessonModel copyWith({
    String? id,
    String? title,
    String? description,
    String? pdfUrl,
    int? readingDuration,
    String? courseId,
    List<String>? keywords,
    List<dynamic>? tests,
    int? version,
  }) {
    return CourseLessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      readingDuration: readingDuration ?? this.readingDuration,
      courseId: courseId ?? this.courseId,
      keywords: keywords ?? this.keywords,
      tests: tests ?? this.tests,
      version: version ?? this.version,
    );
  }

  // Helper methods
  bool get hasPdf => pdfUrl != null && pdfUrl!.isNotEmpty;
  bool get hasKeywords => keywords.isNotEmpty;
  bool get hasTests => tests.isNotEmpty;
  
  // Format reading duration
  String get formattedReadingDuration {
    if (readingDuration <= 0) return "No duration specified";
    if (readingDuration < 60) return "${readingDuration}m";
    
    int hours = readingDuration ~/ 60;
    int minutes = readingDuration % 60;
    
    if (minutes == 0) return "${hours}h";
    return "${hours}h ${minutes}m";
  }

  @override
  String toString() {
    return 'CourseLessonModel(id: $id, title: $title, description: $description, pdfUrl: $pdfUrl, readingDuration: $readingDuration, courseId: $courseId, keywords: $keywords, tests: $tests, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseLessonModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.pdfUrl == pdfUrl &&
        other.readingDuration == readingDuration &&
        other.courseId == courseId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        (pdfUrl?.hashCode ?? 0) ^
        readingDuration.hashCode ^
        courseId.hashCode;
  }
}