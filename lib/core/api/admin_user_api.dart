import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../../domain/models/admin_user_model.dart';
import '../services/auth_token_service.dart';

/// Gọi nhóm endpoint /admin/users (chỉ ADMIN có quyền).
class AdminUserApi {
  Future<Map<String, String>> _headers(String action) async {
    final token = await AuthTokenService.getValidAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('User is not signed in, cannot $action');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Never _fail(String action, http.Response response) {
    throw Exception(
      '$action failed: ${response.statusCode} - ${response.body}',
    );
  }

  /// Trang user + cờ còn trang sau không (PageResponse.hasNext của BE).
  Future<({List<AdminUserModel> items, bool hasNext})> getUsers({
    int page = 0,
    int size = 20,
  }) async {
    final response = await http
        .get(
          Uri.parse(ApiConstants.adminUsersUrl(page: page, size: size)),
          headers: await _headers('load users'),
        )
        .timeout(ApiConstants.timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _fail('Load users', response);
    }

    final data = (jsonDecode(response.body)
        as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final items = (data['items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AdminUserModel.fromJson)
        .toList();
    return (items: items, hasNext: data['hasNext'] == true);
  }

  Future<AdminUserModel> updateStatus(String id, String status) async {
    final response = await http
        .patch(
          Uri.parse(ApiConstants.adminUserStatusUrl(id)),
          headers: await _headers('update user status'),
          body: jsonEncode({'status': status}),
        )
        .timeout(ApiConstants.timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _fail('Update user status', response);
    }
    return _detailFrom(response);
  }

  Future<AdminUserModel> assignRoles(String id, List<String> roleNames) async {
    final response = await http
        .patch(
          Uri.parse(ApiConstants.adminUserRolesUrl(id)),
          headers: await _headers('assign roles'),
          body: jsonEncode({'roleNames': roleNames}),
        )
        .timeout(ApiConstants.timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _fail('Assign roles', response);
    }
    return _detailFrom(response);
  }

  /// BE trả thông báo kèm mật khẩu tạm — hiển thị cho admin chuyển lại user.
  Future<String> resetPassword(String id) async {
    final response = await http
        .post(
          Uri.parse(ApiConstants.adminUserResetPasswordUrl(id)),
          headers: await _headers('reset password'),
        )
        .timeout(ApiConstants.timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _fail('Reset password', response);
    }
    return (jsonDecode(response.body) as Map<String, dynamic>)['data']
            as String? ??
        '';
  }

  Future<void> softDelete(String id) async {
    final response = await http
        .delete(
          Uri.parse(ApiConstants.adminUserUrl(id)),
          headers: await _headers('delete user'),
        )
        .timeout(ApiConstants.timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _fail('Delete user', response);
    }
  }

  AdminUserModel _detailFrom(http.Response response) {
    final data = (jsonDecode(response.body)
        as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return AdminUserModel.fromJson(data);
  }
}
