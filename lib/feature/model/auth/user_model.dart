class UserModel {
  final String id;
  final String email;
  final String name;
  final String? image;
  final String role;
  final String token;
  final List<dynamic> enrollments;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.image,
    required this.role,
    required this.token,
    required this.enrollments,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? json;

    return UserModel(
      id: userJson['_id'] ?? '',
      email: userJson['email'] ?? '',
      name: userJson['name'] ?? 'Default Name',
      image: userJson['image'] ?? 'assets/logo.png',
      role: userJson['role'] ?? '',
      token: json['accessToken'] ?? '', // Added null safety
      enrollments: userJson['enrollments'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'name': name,
      'image': image,
      'role': role,
      'accessToken': token,
      'enrollments': enrollments,
    };
  }
}
