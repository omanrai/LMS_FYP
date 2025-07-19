class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? image;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.image,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? 'Default Name',
      image: json['image'] ?? 'assets/logo.jpg',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'name': name,
      'image': image,
      'role': role,
    };
  }
}
