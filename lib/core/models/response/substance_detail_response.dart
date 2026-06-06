class SubstanceDetailResponse {
  final String substanceId;

  final String? formula;
  final String? name;
  final String? vietnameseName;
  final String? chemicalGroup;
  final String? state;

  final ElementDetailResponse? elementDetail;
  final CompoundDetailResponse? compoundDetail;

  const SubstanceDetailResponse({
    required this.substanceId,
    this.formula,
    this.name,
    this.vietnameseName,
    this.chemicalGroup,
    this.state,
    this.elementDetail,
    this.compoundDetail,
  });

  factory SubstanceDetailResponse.fromJson(Map<String, dynamic> json) {
    return SubstanceDetailResponse(
      substanceId: json['substanceId']?.toString() ?? '',
      formula: json['formula']?.toString(),
      name: json['name']?.toString(),
      vietnameseName: json['vietnameseName']?.toString(),
      chemicalGroup: json['chemicalGroup']?.toString(),
      state: json['state']?.toString(),
      elementDetail: json['elementDetail'] is Map
          ? ElementDetailResponse.fromJson(
        Map<String, dynamic>.from(json['elementDetail']),
      )
          : null,
      compoundDetail: json['compoundDetail'] is Map
          ? CompoundDetailResponse.fromJson(
        Map<String, dynamic>.from(json['compoundDetail']),
      )
          : null,
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

  String get displayFormula => formula ?? '';
}

class ElementDetailResponse {
  final int? atomicNumber;
  final String? symbol;
  final String? periodicCategory;
  final double? atomicMass;
  final int? period;
  final int? groupNumber;

  const ElementDetailResponse({
    this.atomicNumber,
    this.symbol,
    this.periodicCategory,
    this.atomicMass,
    this.period,
    this.groupNumber,
  });

  factory ElementDetailResponse.fromJson(Map<String, dynamic> json) {
    return ElementDetailResponse(
      atomicNumber: _parseInt(json['atomicNumber']),
      symbol: json['symbol']?.toString(),
      periodicCategory: json['periodicCategory']?.toString(),
      atomicMass: _parseDouble(json['atomicMass']),
      period: _parseInt(json['period']),
      groupNumber: _parseInt(json['groupNumber']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class CompoundDetailResponse {
  final String? iupacName;
  final String? casNumber;
  final String? compoundClass;
  final String? usageNote;
  final bool reactionProductOnly;
  final bool physicalInKit;

  const CompoundDetailResponse({
    this.iupacName,
    this.casNumber,
    this.compoundClass,
    this.usageNote,
    required this.reactionProductOnly,
    required this.physicalInKit,
  });

  factory CompoundDetailResponse.fromJson(Map<String, dynamic> json) {
    return CompoundDetailResponse(
      iupacName: json['iupacName']?.toString(),
      casNumber: json['casNumber']?.toString(),
      compoundClass: json['compoundClass']?.toString(),
      usageNote: json['usageNote']?.toString(),
      reactionProductOnly: json['reactionProductOnly'] == true,
      physicalInKit: json['physicalInKit'] == true,
    );
  }
}