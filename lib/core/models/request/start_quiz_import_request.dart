class StartQuizImportRequest {
  final String lessonCode;
  final String s3Key;
  final String originalFilename;

  const StartQuizImportRequest({
    required this.lessonCode,
    required this.s3Key,
    required this.originalFilename,
  });

  Map<String, dynamic> toJson() {
    return {
      'lessonCode': lessonCode,
      's3Key': s3Key,
      'originalFilename': originalFilename,
    };
  }
}