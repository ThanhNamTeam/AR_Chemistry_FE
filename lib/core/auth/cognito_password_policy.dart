/// Quy tắc mật khẩu AWS Cognito user pool.
class CognitoPasswordPolicy {
  CognitoPasswordPolicy._();

  static String hintVi =
      'Tối thiểu 8 ký tự, có chữ hoa, chữ thường, số và ký tự đặc biệt (vd: Test123!)';

  static String hintEn =
      'Min 8 chars with upper, lower, number and symbol (e.g. Test123!)';

  static String? validate(String? password) {
    if (password == null || password.isEmpty) return null;
    if (password.length < 8) return 'min8';
    if (!password.contains(RegExp(r'[A-Z]'))) return 'upper';
    if (!password.contains(RegExp(r'[a-z]'))) return 'lower';
    if (!password.contains(RegExp(r'[0-9]'))) return 'digit';
    if (!password.contains(RegExp(r'[^A-Za-z0-9]'))) return 'symbol';
    return null;
  }
}
