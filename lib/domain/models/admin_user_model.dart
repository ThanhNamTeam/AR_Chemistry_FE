/// User dưới góc nhìn admin — khớp AdminUsersResponse/AdminUserDetailResponse
/// của backend (hai DTO hiện cùng field nên dùng chung một model).
class AdminUserModel {
  final String cognitoSub;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? phoneNumber;

  /// ACTIVE / INACTIVE / DELETED / REJECTED / BLOCKED (enum UserStatus BE).
  final String status;

  /// ROLE_STUDENT / ROLE_TEACHER / ROLE_STAFF / ROLE_ADMIN.
  final List<String> roles;

  const AdminUserModel({
    required this.cognitoSub,
    required this.email,
    required this.status,
    required this.roles,
    this.fullName,
    this.avatarUrl,
    this.phoneNumber,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    return AdminUserModel(
      cognitoSub: json['cognitoSub'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      roles: rawRoles is List
          // BE trả Set<RoleUsersResponse> dạng [{roleName: ROLE_X}, ...]
          ? rawRoles
              .map((r) => r is Map ? '${r['roleName']}' : '$r')
              .where((r) => r.startsWith('ROLE_'))
              .toList()
          : const [],
    );
  }

  String get displayName =>
      (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : email;
}
