class CorseTestQuestion {
  final String? id;
  final String question;
  final List<String> options;

  CorseTestQuestion({this.id, required this.question, required this.options});

  factory CorseTestQuestion.fromJson(Map<String, dynamic> json) {
    return CorseTestQuestion(
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

  CorseTestQuestion copyWith({String? id, String? question, List<String>? options}) {
    return CorseTestQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
    );
  }

  @override
  String toString() {
    return 'CorseTestQuestion(id: $id, question: $question, options: $options)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CorseTestQuestion &&
        other.id == id &&
        other.question == question;
  }

  @override
  int get hashCode {
    return id.hashCode ^ question.hashCode;
  }
}

// Model for the complete test/quiz
class CourseTestModel {
  final String? id;
  final String title;
  final String lessonId;
  final List<CorseTestQuestion> questions;
  final int correctAnswer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CourseTestModel({
    this.id,
    required this.title,
    required this.lessonId,
    required this.questions,
    required this.correctAnswer,
    this.createdAt,
    this.updatedAt,
  });

  factory CourseTestModel.fromJson(Map<String, dynamic> json) {
    return CourseTestModel(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      lessonId: json['lesson'] is String
          ? json['lesson']
          : json['lesson'] is Map<String, dynamic>
          ? json['lesson']['_id'] ?? json['lessonId'] ?? ''
          : json['lessonId'] ?? '',
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => CorseTestQuestion.fromJson(q as Map<String, dynamic>))
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
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      'lesson': lessonId,
      'questions': questions.map((q) => q.toJson()).toList(),
      'correctAnswer': correctAnswer,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  CourseTestModel copyWith({
    String? id,
    String? title,
    String? lessonId,
    List<CorseTestQuestion>? questions,
    int? correctAnswer,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return CourseTestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      lessonId: lessonId ?? this.lessonId,
      questions: questions ?? this.questions,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CorseTestQuestionModel(id: $id, title: $title, lessonId: $lessonId, questions: ${questions.length}, correctAnswer: $correctAnswer)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseTestModel &&
        other.id == id &&
        other.title == title &&
        other.lessonId == lessonId &&
        other.correctAnswer == correctAnswer;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        lessonId.hashCode ^
        correctAnswer.hashCode;
  }
}
