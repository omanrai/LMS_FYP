// course_model.dart

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String? coverImage;
  final List<dynamic> lessons; // You can create a Lesson class later
  final int version;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.coverImage,
    required this.lessons,
    required this.version,
  });

  // Factory constructor to create Course from JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['image'] ?? '',
      lessons: json['lessons'] ?? [],
      version: json['__v'] ?? 0,
    );
  }

  // Convert Course to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'image': coverImage,
      'lessons': lessons,
      '__v': version,
    };
  }

  // Create a copy of the course with modified properties
  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
    List<dynamic>? lessons,
    int? version,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: image ?? this.coverImage,
      lessons: lessons ?? this.lessons,
      version: version ?? this.version,
    );
  }

  @override
  String toString() {
    return 'Course{id: $id, title: $title, description: $description}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
