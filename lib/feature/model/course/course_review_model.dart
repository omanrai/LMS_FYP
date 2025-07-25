import '../auth/user_model.dart';
import 'course_model.dart';

class CourseRemarkModel {
  final CourseModel course;
  final UserModel user;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseRemarkModel({
    required this.course,
    required this.user,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create CourseRemark from JSON
  factory CourseRemarkModel.fromJson(Map<String, dynamic> json) {
    return CourseRemarkModel(
      course: CourseModelExtension.fromCourseRemarkJson(json['course']),

      user: UserModelExtension.fromCourseRemarkJson(
        json['user'] as Map<String, dynamic>,
      ),
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Method to convert CourseRemark to JSON
  Map<String, dynamic> toJson() {
    return {
      'course': course.toJson(),
      'user': user.toJson(),
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Method to create a copy with modified fields
  CourseRemarkModel copyWith({
    CourseModel? course,
    UserModel? user,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return CourseRemarkModel(
      course: course ?? this.course,
      user: user ?? this.user,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CourseRemark{courseTitle: ${course.title}, userName: ${user.name}, rating: $rating, comment: $comment}';
  }

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;
  //   return other is CourseRemark && other.id == id;
  // }

  // @override
  // int get hashCode => id.hashCode;
}

// Enhanced UserModel extension for CourseRemark compatibility
extension UserModelExtension on UserModel {
  // Create a minimal UserModel from CourseRemark user data
  static UserModel fromCourseRemarkJson(Map<String, dynamic> userJson) {
    return UserModel(
      id: userJson['_id'] ?? '',
      email: userJson['email'] ?? '',
      name: userJson['name'] ?? 'Default Name',
      image: null,
      role: '',
      token: '',
      enrollments: [],
    );
  }
}

extension CourseModelExtension on CourseModel {
  static CourseModel fromCourseRemarkJson(dynamic courseJson) {
    if (courseJson is String) {
      // Only ID was provided
      return CourseModel(
        id: courseJson,
        title: '',
        description: '',
        coverImage: '',
        lessons: [],
        lessonIds: [],
        teacherId: '',
        reviewIds: [],
        version: 0,
      );
    } else if (courseJson is Map<String, dynamic>) {
      // Full object
      return CourseModel(
        id: courseJson['_id'] ?? '',
        title: courseJson['title'] ?? '',
        description: '',
        coverImage: '',
        lessons: [],
        lessonIds: [],
        teacherId: '',
        reviewIds: [],
        version: 0,
      );
    } else {
      throw Exception('Invalid course data in CourseRemark JSON');
    }
  }
}

// Import your existing UserModel
// Remove the User class since we'll use UserModel instead

// Helper class for parsing list of CourseRemarks
class CourseRemarkList {
  static List<CourseRemarkModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => CourseRemarkModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> toJsonList(
    List<CourseRemarkModel> remarks,
  ) {
    return remarks.map((remark) => remark.toJson()).toList();
  }
}
