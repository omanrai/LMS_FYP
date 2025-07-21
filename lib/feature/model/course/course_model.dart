import 'dart:developer';

import 'course_lesson_model.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String? coverImage;
  final List<CourseLessonModel> lessons;
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
    final String title = json['title'] ?? '';
    final String description = json['description'] ?? '';
    final String? coverImage = json['image'];

    log('Course Title: $title');
    log('Course Description: $description');
    log('Course Cover Image: $coverImage');

    // Handle lessons parsing with null safety
    List<CourseLessonModel> parsedLessons = [];
    if (json['lessons'] != null && json['lessons'] is List) {
      parsedLessons = (json['lessons'] as List)
          .where((lesson) => lesson != null)
          .map((lesson) {
            log('Parsing Lesson: $lesson');
            return CourseLessonModel.fromJson(lesson as Map<String, dynamic>);
          })
          .toList();
    }

    return CourseModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['image'],
      lessons: parsedLessons,
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
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      '__v': version,
    };
  }

  // Create a copy of the course with modified properties
  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImage,
    List<CourseLessonModel>? lessons,
    int? version,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      lessons: lessons ?? this.lessons,
      version: version ?? this.version,
    );
  }

  // Helper methods for lesson management
  bool get hasLessons => lessons.isNotEmpty;
  int get lessonCount => lessons.length;

  // Get lesson by ID
  CourseLessonModel? getLessonById(String lessonId) {
    try {
      return lessons.firstWhere((lesson) => lesson.id == lessonId);
    } catch (e) {
      return null;
    }
  }

  // Get lessons by keyword
  List<CourseLessonModel> getLessonsByKeyword(String keyword) {
    return lessons
        .where(
          (lesson) => lesson.keywords.any(
            (k) => k.toLowerCase().contains(keyword.toLowerCase()),
          ),
        )
        .toList();
  }

  @override
  String toString() {
    return 'CourseModel{id: $id, title: $title, description: $description, lessonsCount: ${lessons.length}}';
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
