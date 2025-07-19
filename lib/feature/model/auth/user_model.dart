import 'dart:developer';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? image;
  final String role;
  final String token;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.image,
    required this.role,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? json;
    log("user json in user model : $userJson");

    return UserModel(
      id: userJson['_id'] ?? '',
      email: userJson['email'] ?? '',
      name: userJson['name'] ?? 'Default Name',
      image: userJson['image'] ?? 'assets/logo.png',
      role: userJson['role'] ?? '',
      token: json['accessToken'], // top-level token
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'name': name,
      'image': image,
      'role': role,
      'accessToken': token, // Include token when serializing
    };
  }
}
