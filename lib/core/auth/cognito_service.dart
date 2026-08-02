import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class CognitoService {

  Future<String> loginGoogle() async {

    final result = await Amplify.Auth.signInWithWebUI(
      provider: AuthProvider.google,
    );

    if (!result.isSignedIn) {
      throw Exception();
    }

    final session =
    await Amplify.Auth.fetchAuthSession()
    as CognitoAuthSession;

    return session.userPoolTokensResult
        .value
        .idToken
        .raw;
  }

  /// Lấy URL ảnh đại diện Google từ claim `picture` trong ID token.
  ///
  /// CỐ Ý không dùng `Amplify.Auth.fetchUserAttributes()`: hàm đó gọi API
  /// `GetUser` của Cognito và đòi scope `aws.cognito.signin.user.admin`.
  /// App client hiện tại không có scope đó nên luôn ném:
  ///   NotAuthorizedServiceException: "Access Token does not have required scopes"
  ///
  /// ID token thì app đã cầm sẵn sau khi đăng nhập và mang đủ claim hồ sơ
  /// (`email`, `name`, `picture`...), nên đọc thẳng từ đó: không cần thêm
  /// scope, không cần gọi mạng, không phải sửa cấu hình AWS.
  ///
  /// Trả về `null` nếu chưa đăng nhập, hoặc user pool chưa map `picture`
  /// từ Google IdP vào token.
  Future<String?> fetchAvatarUrl() async {
    try {
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;

      final tokens = session.userPoolTokensResult.valueOrNull;
      if (tokens == null) {
        safePrint('AVATAR-DEBUG chua dang nhap (khong co token)');
        return null;
      }

      final claims = _decodeJwtPayload(tokens.idToken.raw);
      if (claims == null) return null;

      // Log chẩn đoán: nếu danh sách này KHÔNG có 'picture' thì user pool chưa
      // map attribute đó từ Google IdP -> phải sửa ở AWS Console, code phía
      // app không cứu được.
      safePrint('AVATAR-DEBUG idToken claims: ${claims.keys.toList()}');

      final picture = claims['picture'];
      if (picture is! String || picture.trim().isEmpty) {
        safePrint('AVATAR-DEBUG khong co claim "picture" trong ID token');
        return null;
      }

      safePrint('AVATAR-DEBUG picture raw = $picture');
      return _normalizePictureValue(picture);
    } on Exception catch (e) {
      safePrint('AVATAR-DEBUG fetchAvatarUrl failed: $e');
    }
    return null;
  }

  /// Giải mã phần payload của JWT (phần giữa) thành map claim.
  ///
  /// Base64Url trong JWT bỏ padding nên phải `normalize` trước khi decode.
  Map<String, dynamic>? _decodeJwtPayload(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on Exception catch (e) {
      safePrint('AVATAR-DEBUG decode ID token failed: $e');
      return null;
    }
  }

  /// Google thường trả thẳng URL, nhưng một số cấu hình IdP lại bọc trong JSON
  /// dạng `{"data":[{"url":"..."}]}`. Chuẩn hoá về URL thuần.
  String? _normalizePictureValue(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final match = RegExp(r'https?://[^"\\\s]+').firstMatch(value);
    return match?.group(0);
  }
}