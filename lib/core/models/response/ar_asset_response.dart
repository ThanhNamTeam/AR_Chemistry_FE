class ArAssetResponse {
  final int markerVersion;
  final int reactionVersion;
  final String markerUrl;
  final String reactionUrl;

  ArAssetResponse({
    required this.markerVersion,
    required this.reactionVersion,
    required this.markerUrl,
    required this.reactionUrl,
  });

  factory ArAssetResponse.fromJson(Map<String, dynamic> json) {
    return ArAssetResponse(
      markerVersion: json['markerVersion'] ?? 0,
      reactionVersion: json['reactionVersion'] ?? 0,
      markerUrl: json['markerUrl']?.toString() ?? '',
      reactionUrl: json['reactionUrl']?.toString() ?? '',
    );
  }
}