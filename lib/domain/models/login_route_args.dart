class LoginRouteArgs {
  final bool registrationSuccess;

  const LoginRouteArgs({this.registrationSuccess = false});
}

class HomeRouteArgs {
  final String? welcomeMessage;

  const HomeRouteArgs({this.welcomeMessage});
}

class LoginResult {
  final bool isFirstLogin;
  final String fullName;

  const LoginResult({
    required this.isFirstLogin,
    required this.fullName,
  });
}
