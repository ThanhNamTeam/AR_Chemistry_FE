/// App area that owns its own theme + locale (auth = onboarding / login).
enum AppPortal {
  auth,
  user,
  staff,
  admin;

  String get storageSuffix => name;
}
