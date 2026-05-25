class FeedbackRequest {
  final String title;
  final String content;
  final String type;
  final bool anonymous;
  final String? imageUrl;
  final String? appVersion;
  final String? deviceInfo;

  const FeedbackRequest({
    required this.title,
    required this.content,
    required this.type,
    required this.anonymous,
    this.imageUrl,
    this.appVersion,
    this.deviceInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'content': content.trim(),
      'type': type,
      'anonymous': anonymous,
      if (imageUrl != null && imageUrl!.trim().isNotEmpty)
        'imageUrl': imageUrl,
      if (appVersion != null && appVersion!.trim().isNotEmpty)
        'appVersion': appVersion,
      if (deviceInfo != null && deviceInfo!.trim().isNotEmpty)
        'deviceInfo': deviceInfo,
    };
  }
}