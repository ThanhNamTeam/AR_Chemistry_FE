class LoginRouteArgs {
  final bool registrationSuccess;
  final bool passwordResetSuccess;

  const LoginRouteArgs({
    this.registrationSuccess = false,
    this.passwordResetSuccess = false,
  });
}

class HomeRouteArgs {
  final String? welcomeMessage;

  const HomeRouteArgs({this.welcomeMessage});
}

class LoginResult {
  final bool isFirstLogin;
  final String displayName;

  const LoginResult({
    required this.isFirstLogin,
    required this.displayName,
  });
}
