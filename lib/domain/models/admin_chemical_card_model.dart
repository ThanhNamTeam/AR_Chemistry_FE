class AdminChemicalCardModel {
  final String id;
  final String cardCode;
  final String qrPayload;

  final String? substanceId;
  final String? formula;
  final String? substanceName;
  final String? vietnameseName;

  final String? type;
  final String? chemicalGroup;
  final String? state;

  final String? displayName;

  final String? imageUrl;
  final String? frontImageUrl;
  final String? backImageUrl;

  final bool active;

  const AdminChemicalCardModel({
    required this.id,
    required this.cardCode,
    required this.qrPayload,
    this.substanceId,
    this.formula,
    this.substanceName,
    this.vietnameseName,
    this.type,
    this.chemicalGroup,
    this.state,
    this.displayName,
    this.imageUrl,
    this.frontImageUrl,
    this.backImageUrl,
    required this.active,
  });

  factory AdminChemicalCardModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AdminChemicalCardModel(
      id: json['id']?.toString() ?? '',
      cardCode: json['cardCode']?.toString() ?? '',
      qrPayload: json['qrPayload']?.toString() ?? '',
      substanceId: json['substanceId']?.toString(),
      formula: json['formula']?.toString(),
      substanceName: json['substanceName']?.toString(),
      vietnameseName: json['vietnameseName']?.toString(),
      type: json['type']?.toString(),
      chemicalGroup: json['chemicalGroup']?.toString(),
      state: json['state']?.toString(),
      displayName: json['displayName']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      frontImageUrl: json['frontImageUrl']?.toString(),
      backImageUrl: json['backImageUrl']?.toString(),
      active: json['active'] == true,
    );
  }
}