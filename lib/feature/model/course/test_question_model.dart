// Individual Question model
import 'course_lesson_model.dart';

// Main Test Question Model (represents the entire test)
class TestQuestionModel {
  final String? id;
  final String title;
  final CourseLessonModel? lesson;
  final List<QuestionModel> questions;
  final int correctAnswer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TestQuestionModel({
    this.id,
    required this.title,
    this.lesson,
    required this.questions,
    required this.correctAnswer,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create TestQuestionModel from JSON
  factory TestQuestionModel.fromJson(Map<String, dynamic> json) {
    return TestQuestionModel(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      lesson: json['lesson'] != null
          ? CourseLessonModel.fromJson(json['lesson'])
          : null,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromJson(q))
              .toList() ??
          [],
      correctAnswer: json['correctAnswer'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Convert TestQuestionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      if (lesson != null) 'lesson': lesson!.toJson(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'correctAnswer': correctAnswer,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Create a copy with updated values
  TestQuestionModel copyWith({
    String? id,
    String? title,
    CourseLessonModel? lesson,
    List<QuestionModel>? questions,
    int? correctAnswer,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TestQuestionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      lesson: lesson ?? this.lesson,
      questions: questions ?? this.questions,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convenience getters for backward compatibility with your existing UI code
  String get question => questions.isNotEmpty ? questions.first.question : '';
  List<String> get options =>
      questions.isNotEmpty ? questions.first.options : [];
  String get lessonId => lesson?.id ?? '';

  @override
  String toString() {
    return 'TestQuestionModel(id: $id, title: $title, questions: ${questions.length}, correctAnswer: $correctAnswer, lessonId: $lessonId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestQuestionModel &&
        other.id == id &&
        other.title == title &&
        other.correctAnswer == correctAnswer &&
        other.lessonId == lessonId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        correctAnswer.hashCode ^
        lessonId.hashCode;
  }
}

class QuestionModel {
  final String? id;
  final String question;
  final List<String> options;

  QuestionModel({this.id, required this.question, required this.options});

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['_id'] ?? json['id'],
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'question': question,
      'options': options,
    };
  }
}
