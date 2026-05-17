import 'package:flutter/foundation.dart';

import '../../../core/auth/role_accounts.dart';
import '../../../core/storage/avatar_storage_service.dart';
import '../../../core/storage/role_session_service.dart';
import '../../../domain/models/user_role.dart';

class RoleSessionProvider extends ChangeNotifier {
  final RoleSessionService _storage = RoleSessionService();

  UserRole? _role;
  String? _email;
  String? _userName;
  String? _userPhone;
  String? _userAvatar;
  String _password = '';

  UserRole? get role => _role;
  String? get email => _email;
  String? get userName => _userName;
  String? get userPhone => _userPhone;
  String? get userAvatar => _userAvatar;

  String get displayName {
    if (_userName != null && _userName!.trim().isNotEmpty) {
      return _userName!.trim();
    }
    final mail = _email;
    if (mail == null || mail.isEmpty) return 'Portal User';
    final at = mail.indexOf('@');
    return at > 0 ? mail.substring(0, at) : mail;
  }

  String get roleLabel => _role?.label ?? '';

  bool get isStaff => _role == UserRole.staff;
  bool get isAdmin => _role == UserRole.admin;

  Future<void> loadSession() async {
    final saved = await _storage.load();
    if (saved != null) {
      _role = saved.role;
      _email = saved.email;
      await _loadProfile();
      notifyListeners();
    }
  }

  Future<void> _loadProfile() async {
    final role = _role;
    if (role == null) return;

    var profile = await _storage.getProfile(role);
    if (profile == null) {
      profile = _defaultProfile(role);
      await _storage.saveProfile(role, profile);
    }

    _userName = profile['fullname'] as String?;
    if (_userName != null && _userName!.trim().isEmpty) _userName = null;
    _userPhone = profile['phone'] as String?;
    _password = profile['password'] as String? ?? _defaultPassword(role);
    final avatar = profile['avatar'] as String?;
    _userAvatar =
        AvatarStorageService.avatarFileExists(avatar) ? avatar : null;
  }

  Map<String, dynamic> _defaultProfile(UserRole role) {
    return {
      'fullname': role == UserRole.staff ? 'Staff Member' : 'Administrator',
      'phone': '',
      'password': _defaultPassword(role),
      if (_email != null) 'email': _email,
    };
  }

  String _defaultPassword(UserRole role) {
    return role == UserRole.staff
        ? RoleAccounts.staffPassword
        : RoleAccounts.adminPassword;
  }

  Future<String?> _persistProfile({String? passwordOverride}) async {
    final role = _role;
    if (role == null || _email == null) return 'Phiên không hợp lệ.';

    await _storage.saveProfile(role, {
      'fullname': _userName ?? '',
      'email': _email,
      'phone': _userPhone ?? '',
      'password': passwordOverride ?? _password,
      if (_userAvatar != null) 'avatar': _userAvatar,
    });
    return null;
  }

  /// Returns staff/admin role if credentials match; null → use normal user login.
  Future<UserRole?> tryRoleLogin(String email, String password) async {
    final normalized = email.trim().toLowerCase();

    UserRole? matchedRole;
    if (normalized == RoleAccounts.staffEmail) {
      matchedRole = UserRole.staff;
    } else if (normalized == RoleAccounts.adminEmail) {
      matchedRole = UserRole.admin;
    } else {
      return null;
    }

    final stored = await _storage.getProfile(matchedRole);
    final expectedPassword = stored?['password'] as String? ??
        _defaultPassword(matchedRole);
    if (password != expectedPassword) return null;

    _role = matchedRole;
    _email = normalized;
    await _storage.save(matchedRole, normalized);
    await _loadProfile();
    notifyListeners();
    return matchedRole;
  }

  Future<String?> updateProfile({
    required String fullName,
    required String phone,
    String? password,
    String? confirmPassword,
  }) async {
    if (_role == null) return 'Phiên không hợp lệ.';
    if (fullName.trim().isEmpty) return 'Họ tên không được để trống.';
    if (phone.trim().isEmpty) return 'Số điện thoại không được để trống.';

    final wantsPasswordChange = password != null && password.isNotEmpty;
    if (wantsPasswordChange) {
      if (password.length < 6) return 'Mật khẩu tối thiểu 6 ký tự.';
      if (password != confirmPassword) return 'Mật khẩu xác nhận không khớp.';
      _password = password;
    }

    _userName = fullName.trim();
    _userPhone = phone.trim();
    await _persistProfile(
      passwordOverride: wantsPasswordChange ? password : null,
    );
    notifyListeners();
    return null;
  }

  Future<String?> updateAvatarFromPath(String pickedPath) async {
    if (_role == null || _email == null) {
      return 'Phiên không hợp lệ.';
    }
    try {
      final saved = await AvatarStorageService.saveAvatar(
        pickedPath,
        '${_role!.name}_$_email',
      );
      _userAvatar = saved;
      await _persistProfile();
      notifyListeners();
      return null;
    } catch (_) {
      return 'Không thể lưu ảnh đại diện.';
    }
  }

  Future<void> logout() async {
    _role = null;
    _email = null;
    _userName = null;
    _userPhone = null;
    _userAvatar = null;
    _password = '';
    await _storage.clear();
    notifyListeners();
  }
}
