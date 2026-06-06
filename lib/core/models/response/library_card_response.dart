class LibraryCardResponse {
  final String substanceId;

  final String? formula;
  final String? name;
  final String? vietnameseName;
  final String? type;
  final String? chemicalGroup;
  final String? state;
  final double? molarMass;
  final bool includedInFullKit;

  const LibraryCardResponse({
    required this.substanceId,
    this.formula,
    this.name,
    this.vietnameseName,
    this.type,
    this.chemicalGroup,
    this.state,
    this.molarMass,
    required this.includedInFullKit,
  });

  factory LibraryCardResponse.fromJson(Map<String, dynamic> json) {
    return LibraryCardResponse(
      substanceId: json['substanceId']?.toString() ?? '',
      formula: json['formula']?.toString(),
      name: json['name']?.toString(),
      vietnameseName: json['vietnameseName']?.toString(),
      type: json['type']?.toString(),
      chemicalGroup: json['chemicalGroup']?.toString(),
      state: json['state']?.toString(),
      molarMass: _parseDouble(json['molarMass']),
      includedInFullKit: json['includedInFullKit'] == true,
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

  String get displayFormula => formula ?? '?';

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}