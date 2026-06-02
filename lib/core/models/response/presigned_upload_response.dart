class PresignedUploadResponse {
  final int uploadFileId;
  final String uploadUrl;
  final String fileUrl;
  final String storageKey;
  final String contentType;

  PresignedUploadResponse({
    required this.uploadFileId,
    required this.uploadUrl,
    required this.fileUrl,
    required this.storageKey,
    required this.contentType,
  });

  factory PresignedUploadResponse.fromJson(Map<String, dynamic> json) {
    return PresignedUploadResponse(
      uploadFileId: json['uploadFileId'],
      uploadUrl: json['uploadUrl'],
      fileUrl: json['fileUrl'],
      storageKey: json['storageKey'],
      contentType: json['contentType'],
    );
  }
}