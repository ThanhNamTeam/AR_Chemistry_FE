class AccountSetupData {
  final String email;
  final String password;
  final String? fullName;

  const AccountSetupData({
    required this.email,
    required this.password,
    this.fullName,
  });
}
