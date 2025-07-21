// test_question_model.dart

class TestQuestionModel {
  final String? id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String lessonId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TestQuestionModel({
    this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.lessonId,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create TestQuestionModel from JSON
  factory TestQuestionModel.fromJson(Map<String, dynamic> json) {
    return TestQuestionModel(
      id: json['_id'] ?? json['id'],
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      lessonId: json['lessonId'] ?? '',
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
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'lessonId': lessonId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Create a copy with updated values
  TestQuestionModel copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswer,
    String? lessonId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TestQuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      lessonId: lessonId ?? this.lessonId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TestQuestionModel(id: $id, question: $question, options: $options, correctAnswer: $correctAnswer, lessonId: $lessonId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestQuestionModel &&
        other.id == id &&
        other.question == question &&
        other.correctAnswer == correctAnswer &&
        other.lessonId == lessonId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        question.hashCode ^
        correctAnswer.hashCode ^
        lessonId.hashCode;
  }
}