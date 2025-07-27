class UserModel {
  final String id;
  final String email;
  final String name;
  final String? image;
  final String role;
  final String token;
  final List<dynamic> enrollments;
  final List<dynamic> notificationTokens;
  final int? version; // For __v field

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.image,
    required this.role,
    required this.token,
    required this.enrollments,
    required this.notificationTokens,
    this.version,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? json;
    return UserModel(
      id: userJson['_id'] ?? '',
      email: userJson['email'] ?? '',
      name: userJson['name'] ?? '',
      image: userJson['image'], // Keep as null if API returns null
      role: userJson['role'] ?? '',
      token: json['accessToken'] ?? '',
      enrollments: userJson['enrollments'] ?? [],
      notificationTokens: userJson['notification_tokens'] ?? [],
      version: userJson['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {
        '_id': id,
        'email': email,
        'name': name,
        'image': image,
        'role': role,
        'enrollments': enrollments,
        'notification_tokens': notificationTokens,
        '__v': version,
      },
      'accessToken': token,
    };
  }
}
