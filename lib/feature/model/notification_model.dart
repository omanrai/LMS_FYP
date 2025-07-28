// Define the NotificationStatus enum
enum NotificationStatus { system, promotion, message, alert, test }

// Extension to handle JSON serialization/deserialization
extension NotificationStatusExtension on NotificationStatus {
  String get toJsonString => toString().split('.').last;

  static NotificationStatus fromJsonString(String value) {
    return NotificationStatus.values.firstWhere(
      (status) => status.toJsonString == value,
      orElse: () => NotificationStatus.system, // Default value if not found
    );
  }
}

class NotificationModel {
  final List<String> recipients;
  final String title;
  final String body;
  final NotificationData? data;
  final String type;
  final NotificationStatus status;
  final bool isRead;
  final DateTime? readAt;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  NotificationModel({
    required this.recipients,
    required this.title,
    required this.body,
    this.data,
    required this.type,
    required this.status,
    required this.isRead,
    this.readAt,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationModel(
        recipients: List<String>.from(json['recipients'] ?? []),
        title: json['title']?.toString() ?? '', // Convert to string safely
        body: json['body']?.toString() ?? '', // Convert to string safely
        data: json['data'] != null
            ? NotificationData.fromJson(json['data'])
            : null,
        type: json['type']?.toString() ?? '', // Convert to string safely
        status: NotificationStatusExtension.fromJsonString(
          json['status']?.toString() ?? 'system', // Convert to string safely
        ),
        isRead: json['isRead'] ?? false,
        readAt: json['readAt'] != null && json['readAt'].toString().isNotEmpty
            ? DateTime.parse(json['readAt'])
            : null,
        id: json['_id']?.toString() ?? '', // Convert to string safely
        createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          json['updatedAt'] ?? DateTime.now().toIso8601String(),
        ),
        version: json['__v'] ?? 0,
      );
    } catch (e) {
      print('Error parsing NotificationModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'recipients': recipients,
      'title': title,
      'body': body,
      'data': data?.toJson(),
      'type': type,
      'status': status.toJsonString,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      '_id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  NotificationModel copyWith({
    List<String>? recipients,
    String? title,
    String? body,
    NotificationData? data,
    String? type,
    NotificationStatus? status,
    bool? isRead,
    DateTime? readAt,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return NotificationModel(
      recipients: recipients ?? this.recipients,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      type: type ?? this.type,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, body: $body, type: $type, status: ${status.toJsonString}, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class NotificationData {
  final String courseId;

  NotificationData({required this.courseId});

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationData(
        courseId:
            json['courseId']?.toString() ?? '', // Convert to string safely
      );
    } catch (e) {
      print('Error parsing NotificationData: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'courseId': courseId};
  }

  NotificationData copyWith({String? courseId}) {
    return NotificationData(courseId: courseId ?? this.courseId);
  }

  @override
  String toString() {
    return 'NotificationData(courseId: $courseId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationData && other.courseId == courseId;
  }

  @override
  int get hashCode => courseId.hashCode;
}
