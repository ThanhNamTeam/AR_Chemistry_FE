class GenerateUploadUrlRequest {
  final String purposeCode;
  final String fileName;
  final String contentType;
  final int fileSize;

  GenerateUploadUrlRequest({
    required this.purposeCode,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'purposeCode': purposeCode,
      'fileName': fileName,
      'contentType': contentType,
      'fileSize': fileSize,
    };
  }
}