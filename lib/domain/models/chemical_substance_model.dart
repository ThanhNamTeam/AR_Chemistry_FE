class ChemicalSubstanceModel {
  final String id;
  final String formula;
  final String name;
  final String? vietnameseName;
  final String type;
  final String chemicalGroup;
  final String state;
  final double? molarMass;
  final bool active;
  final bool includedInFullKit;
  final String? description;
  final String? safetyNote;
  final ElementDetailModel? elementDetail;
  final CompoundDetailModel? compoundDetail;

  /// Tạm thời false. Sau này có API chemical-card thì map lại.
  final bool hasCard;

  const ChemicalSubstanceModel({
    required this.id,
    required this.formula,
    required this.name,
    required this.vietnameseName,
    required this.type,
    required this.chemicalGroup,
    required this.state,
    required this.molarMass,
    required this.active,
    required this.includedInFullKit,
    required this.description,
    required this.safetyNote,
    required this.elementDetail,
    required this.compoundDetail,
    this.hasCard = false,
  });

  String get displayName {
    final viName = vietnameseName?.trim();
    if (viName != null && viName.isNotEmpty) {
      return viName;
    }
    return name;
  }

  bool get isElement => type == 'ELEMENT';

  bool get isCompound => type == 'COMPOUND' || type == 'SIMPLE_MOLECULE';

  factory ChemicalSubstanceModel.fromJson(Map<String, dynamic> json) {
    return ChemicalSubstanceModel(
      id: json['id']?.toString() ?? '',
      formula: json['formula']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      vietnameseName: json['vietnameseName']?.toString(),
      type: json['type']?.toString() ?? '',
      chemicalGroup: json['chemicalGroup']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      molarMass: _toDouble(json['molarMass']),
      active: json['active'] == true,
      includedInFullKit: json['includedInFullKit'] == true,
      description: json['description']?.toString(),
      safetyNote: json['safetyNote']?.toString(),
      elementDetail: json['elementDetail'] is Map<String, dynamic>
          ? ElementDetailModel.fromJson(json['elementDetail'])
          : null,
      compoundDetail: json['compoundDetail'] is Map<String, dynamic>
          ? CompoundDetailModel.fromJson(json['compoundDetail'])
          : null,
      hasCard: json['hasCard'] == true,
    );
  }

  ChemicalSubstanceModel copyWith({
    String? id,
    String? formula,
    String? name,
    String? vietnameseName,
    String? type,
    String? chemicalGroup,
    String? state,
    double? molarMass,
    bool? active,
    bool? includedInFullKit,
    String? description,
    String? safetyNote,
    ElementDetailModel? elementDetail,
    CompoundDetailModel? compoundDetail,
    bool? hasCard,
  }) {
    return ChemicalSubstanceModel(
      id: id ?? this.id,
      formula: formula ?? this.formula,
      name: name ?? this.name,
      vietnameseName: vietnameseName ?? this.vietnameseName,
      type: type ?? this.type,
      chemicalGroup: chemicalGroup ?? this.chemicalGroup,
      state: state ?? this.state,
      molarMass: molarMass ?? this.molarMass,
      active: active ?? this.active,
      includedInFullKit: includedInFullKit ?? this.includedInFullKit,
      description: description ?? this.description,
      safetyNote: safetyNote ?? this.safetyNote,
      elementDetail: elementDetail ?? this.elementDetail,
      compoundDetail: compoundDetail ?? this.compoundDetail,
      hasCard: hasCard ?? this.hasCard,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}

class ElementDetailModel {
  final int? atomicNumber;
  final String? symbol;
  final String? periodicCategory;
  final double? atomicMass;
  final int? period;
  final int? groupNumber;

  const ElementDetailModel({
    required this.atomicNumber,
    required this.symbol,
    required this.periodicCategory,
    required this.atomicMass,
    required this.period,
    required this.groupNumber,
  });

  factory ElementDetailModel.fromJson(Map<String, dynamic> json) {
    return ElementDetailModel(
      atomicNumber: _toInt(json['atomicNumber']),
      symbol: json['symbol']?.toString(),
      periodicCategory: json['periodicCategory']?.toString(),
      atomicMass: ChemicalSubstanceModel._toDouble(json['atomicMass']),
      period: _toInt(json['period']),
      groupNumber: _toInt(json['groupNumber']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }
}

class CompoundDetailModel {
  final String? iupacName;
  final String? casNumber;
  final String? compoundClass;
  final String? usageNote;
  final bool? reactionProductOnly;
  final bool? physicalInKit;

  const CompoundDetailModel({
    required this.iupacName,
    required this.casNumber,
    required this.compoundClass,
    required this.usageNote,
    required this.reactionProductOnly,
    required this.physicalInKit,
  });

  factory CompoundDetailModel.fromJson(Map<String, dynamic> json) {
    return CompoundDetailModel(
      iupacName: json['iupacName']?.toString(),
      casNumber: json['casNumber']?.toString(),
      compoundClass: json['compoundClass']?.toString(),
      usageNote: json['usageNote']?.toString(),
      reactionProductOnly: json['reactionProductOnly'] as bool?,
      physicalInKit: json['physicalInKit'] as bool?,
    );
  }
}