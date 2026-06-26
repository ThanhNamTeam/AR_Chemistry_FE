class ArAssetResponse {
  final int markerVersion;
  final int reactionVersion;
  final String markerUrl;
  final String reactionUrl;
  final int markerSizeBytes;
  final int reactionSizeBytes;

  ArAssetResponse({
    required this.markerVersion,
    required this.reactionVersion,
    required this.markerUrl,
    required this.reactionUrl,
    required this.markerSizeBytes,
    required this.reactionSizeBytes,
  });

  factory ArAssetResponse.fromJson(Map<String, dynamic> json) {
    return ArAssetResponse(
      markerVersion: json['markerVersion'] ?? 0,
      reactionVersion: json['reactionVersion'] ?? 0,
      markerUrl: json['markerUrl']?.toString() ?? '',
      reactionUrl: json['reactionUrl']?.toString() ?? '',
      markerSizeBytes: json['markerSizeBytes'] ?? 0,
      reactionSizeBytes: json['reactionSizeBytes'] ?? 0,
    );
  }
}