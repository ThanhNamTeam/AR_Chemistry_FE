enum AccountSetupSource { google, registration }

enum UserRole { teacher, student }

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

/// Payload aligned with backend fields (e.g. school_name, certificate_url, experience).
class AccountSetupData {
  final String fullName;
  final String email;
  final String password;
  final UserRole role;
  final String? schoolName;
  final String? certificateUrl;
  final String? experience;

  const AccountSetupData({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.schoolName,
    this.certificateUrl,
    this.experience,
  });
}
