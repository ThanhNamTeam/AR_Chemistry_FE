class AdminFeedbackListModel {
  final String id;
  final String title;
  final String type;
  final String status;
  final String priority;
  final String displayName;
  final bool anonymous;
  final DateTime? createdAt;

  const AdminFeedbackListModel({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.priority,
    required this.displayName,
    required this.anonymous,
    this.createdAt,
  });

  factory AdminFeedbackListModel.fromJson(Map<String, dynamic> json) {
    return AdminFeedbackListModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? 'Ẩn danh',
      anonymous: json['anonymous'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}