class ActivationCodeModel {
  final String id;
  final String code;

  final String? kitId;
  final String? kitCode;
  final String? kitName;

  final String status;

  final String? usedByUserId;
  final DateTime? usedAt;
  final DateTime? expiresAt;

  final bool active;
  final String? note;

  const ActivationCodeModel({
    required this.id,
    required this.code,
    this.kitId,
    this.kitCode,
    this.kitName,
    required this.status,
    this.usedByUserId,
    this.usedAt,
    this.expiresAt,
    required this.active,
    this.note,
  });

  factory ActivationCodeModel.fromJson(Map<String, dynamic> json) {
    return ActivationCodeModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      kitId: json['kitId']?.toString(),
      kitCode: json['kitCode']?.toString(),
      kitName: json['kitName']?.toString(),
      status: json['status']?.toString() ?? '',
      usedByUserId: json['usedByUserId']?.toString(),
      usedAt: _parseDate(json['usedAt']),
      expiresAt: _parseDate(json['expiresAt']),
      active: json['active'] == true,
      note: json['note']?.toString(),
    );
  }

  ActivationCodeModel copyWith({
    String? id,
    String? code,
    String? kitId,
    String? kitCode,
    String? kitName,
    String? status,
    String? usedByUserId,
    DateTime? usedAt,
    DateTime? expiresAt,
    bool? active,
    String? note,
  }) {
    return ActivationCodeModel(
      id: id ?? this.id,
      code: code ?? this.code,
      kitId: kitId ?? this.kitId,
      kitCode: kitCode ?? this.kitCode,
      kitName: kitName ?? this.kitName,
      status: status ?? this.status,
      usedByUserId: usedByUserId ?? this.usedByUserId,
      usedAt: usedAt ?? this.usedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      active: active ?? this.active,
      note: note ?? this.note,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}