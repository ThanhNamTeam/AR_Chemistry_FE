class StartQuizImportRequest {
  final String reactionCode;
  final String s3Key;
  final String originalFilename;

  const StartQuizImportRequest({
    required this.reactionCode,
    required this.s3Key,
    required this.originalFilename,
  });

  Map<String, dynamic> toJson() {
    return {
      'reactionCode': reactionCode,
      's3Key': s3Key,
      'originalFilename': originalFilename,
    };
  }
}