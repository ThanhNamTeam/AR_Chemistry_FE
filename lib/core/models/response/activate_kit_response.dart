class ActivateKitResponse {
  final bool success;
  final String? message;

  final String? kitId;
  final String? kitCode;
  final String? kitName;
  final String? activationCode;

  final List<UnlockedSubstanceResponse> unlockedSubstances;

  const ActivateKitResponse({
    required this.success,
    this.message,
    this.kitId,
    this.kitCode,
    this.kitName,
    this.activationCode,
    required this.unlockedSubstances,
  });

  factory ActivateKitResponse.fromJson(Map<String, dynamic> json) {
    final rawUnlockedSubstances = json['unlockedSubstances'];

    return ActivateKitResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      kitId: json['kitId']?.toString(),
      kitCode: json['kitCode']?.toString(),
      kitName: json['kitName']?.toString(),
      activationCode: json['activationCode']?.toString(),
      unlockedSubstances: rawUnlockedSubstances is List
          ? rawUnlockedSubstances
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(UnlockedSubstanceResponse.fromJson)
          .toList()
          : [],
    );
  }
}

class UnlockedSubstanceResponse {
  final String substanceId;

  final String? formula;
  final String? name;
  final String? vietnameseName;
  final String? chemicalGroup;
  final String? state;

  const UnlockedSubstanceResponse({
    required this.substanceId,
    this.formula,
    this.name,
    this.vietnameseName,
    this.chemicalGroup,
    this.state,
  });

  factory UnlockedSubstanceResponse.fromJson(Map<String, dynamic> json) {
    return UnlockedSubstanceResponse(
      substanceId: json['substanceId']?.toString() ?? '',
      formula: json['formula']?.toString(),
      name: json['name']?.toString(),
      vietnameseName: json['vietnameseName']?.toString(),
      chemicalGroup: json['chemicalGroup']?.toString(),
      state: json['state']?.toString(),
    );
  }

  String get displayName {
    if (vietnameseName != null && vietnameseName!.isNotEmpty) {
      return vietnameseName!;
    }

    if (name != null && name!.isNotEmpty) {
      return name!;
    }

    return formula ?? 'Unknown substance';
  }
}