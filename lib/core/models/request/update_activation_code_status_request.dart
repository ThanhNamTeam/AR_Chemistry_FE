class UpdateActivationCodeStatusRequest {
  final String status;

  const UpdateActivationCodeStatusRequest({
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}