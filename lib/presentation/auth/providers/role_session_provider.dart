import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';

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

    debugPrint('SAVED_SESSION: $saved');

    if (saved != null) {

      debugPrint('ROLE: ${saved.role}');
      debugPrint('EMAIL: ${saved.email}');

      _role = saved.role;
      _email = saved.email;

      debugPrint('SET_ROLE: $_role');

      await _loadProfile();

      debugPrint('IS_ADMIN: $isAdmin');
      debugPrint('IS_STAFF: $isStaff');

      notifyListeners();
    } else {
      debugPrint('NO SAVED SESSION');
    }
  }

  Future<void> saveSession({
    required UserRole role,
    required String email,
  }) async {

    _role = role;
    _email = email;

    await _storage.save(role, email);

    await _loadProfile();

    notifyListeners();
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
    final avatar = profile['avatar'] as String?;
    _userAvatar =
        AvatarStorageService.avatarFileExists(avatar) ? avatar : null;
  }

  Map<String, dynamic> _defaultProfile(UserRole role) {
    return {
      'fullname': role == UserRole.staff ? 'Staff Member' : 'Administrator',
      'phone': '',
      if (_email != null) 'email': _email,
    };
  }

  Future<String?> _persistProfile({String? passwordOverride}) async {
    final role = _role;
    if (role == null || _email == null) return 'Phiên không hợp lệ.';

    await _storage.saveProfile(role, {
      'fullname': _userName ?? '',
      'email': _email,
      'phone': _userPhone ?? '',
      if (_userAvatar != null) 'avatar': _userAvatar,
    });
    return null;
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

    try {

      await Amplify.Auth.signOut();

      debugPrint("Cognito logout success");

    } catch (e, s) {

      debugPrint(e.toString());
      debugPrint(s.toString());
    }

    _role = null;
    _email = null;
    _userName = null;
    _userPhone = null;
    _userAvatar = null;

    await _storage.clear();

    notifyListeners();
  }

  Future<void> clearLocalSessionOnly() async {
    _role = null;
    _email = null;

    // Nếu RoleSessionProvider có lưu role/email vào storage riêng,
    // thì clear storage đó ở đây.
    // Tuyệt đối KHÔNG gọi Amplify.Auth.signOut() trong hàm này.

    notifyListeners();
  }
}
