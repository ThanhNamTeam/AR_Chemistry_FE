class StudentReactionSubstanceModel {
  final String substanceId;
  final String formula;
  final String name;
  final String? vietnameseName;

  final String? chemicalGroup;
  final String? state;

  final int coefficient;
  final int substanceOrder;

  const StudentReactionSubstanceModel({
    required this.substanceId,
    required this.formula,
    required this.name,
    this.vietnameseName,
    this.chemicalGroup,
    this.state,
    required this.coefficient,
    required this.substanceOrder,
  });

  factory StudentReactionSubstanceModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StudentReactionSubstanceModel(
      substanceId:
      json['substanceId']?.toString() ?? '',
      formula:
      json['formula']?.toString() ?? '',
      name:
      json['name']?.toString() ?? '',
      vietnameseName:
      json['vietnameseName']?.toString(),
      chemicalGroup:
      json['chemicalGroup']?.toString(),
      state:
      json['state']?.toString(),
      coefficient:
      (json['coefficient'] as num?)?.toInt() ?? 1,
      substanceOrder:
      (json['substanceOrder'] as num?)?.toInt() ?? 0,
    );
  }
}