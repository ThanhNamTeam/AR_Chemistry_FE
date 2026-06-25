import 'package:flutter/foundation.dart';

@immutable
class AdminFeedbackModel {
  final String id;
  final String title;
  final String content;
  final String type;
  final String status;
  final String priority;
  final bool anonymous;
  final String? displayName;
  final String? imageUrl;
  final String? staffReply;
  final String? appVersion;
  final String? deviceInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminFeedbackModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.status,
    required this.priority,
    required this.anonymous,
    this.displayName,
    this.imageUrl,
    this.staffReply,
    this.appVersion,
    this.deviceInfo,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminFeedbackModel.fromJson(Map<String, dynamic> json) {
    return AdminFeedbackModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      anonymous: json['anonymous'] == true,
      displayName: json['displayName']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      staffReply: json['staffReply']?.toString(),
      appVersion: json['appVersion']?.toString(),
      deviceInfo: json['deviceInfo']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'status': status,
      'priority': priority,
      'anonymous': anonymous,
      'displayName': displayName,
      'imageUrl': imageUrl,
      'staffReply': staffReply,
      'appVersion': appVersion,
      'deviceInfo': deviceInfo,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}