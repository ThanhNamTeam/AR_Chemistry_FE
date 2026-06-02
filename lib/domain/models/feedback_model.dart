enum FeedbackType {
  bug('BUG', 'Báo lỗi'),
  uiUx('UI_UX', 'Giao diện / trải nghiệm'),
  performance('PERFORMANCE', 'Hiệu năng'),
  featureRequest('FEATURE_REQUEST', 'Đề xuất tính năng'),
  contentError('CONTENT_ERROR', 'Sai nội dung'),
  question('QUESTION', 'Câu hỏi'),
  other('OTHER', 'Khác');

  const FeedbackType(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class FeedbackPayload {
  final String title;
  final String content;
  final FeedbackType type;
  final bool anonymous;
  final String? imageUrl;

  const FeedbackPayload({
    required this.title,
    required this.content,
    required this.type,
    required this.anonymous,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'type': type.apiValue,
        'anonymous': anonymous,
        if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
      };
}
