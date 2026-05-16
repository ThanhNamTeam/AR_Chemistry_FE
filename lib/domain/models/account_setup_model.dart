enum AccountSetupSource { google, registration }

/// Passed when navigating to [CompleteProfileScreen].
class AccountSetupRouteArgs {
  final AccountSetupSource source;
  final String? prefilledEmail;
  final String? prefilledFullName;

  const AccountSetupRouteArgs({
    required this.source,
    this.prefilledEmail,
    this.prefilledFullName,
  });

  factory AccountSetupRouteArgs.registration() =>
      const AccountSetupRouteArgs(source: AccountSetupSource.registration);

  bool get lockEmail => source == AccountSetupSource.google;
}

class AccountSetupData {
  final String fullName;
  final String email;
  final String password;

  const AccountSetupData({
    required this.fullName,
    required this.email,
    required this.password,
  });
}
