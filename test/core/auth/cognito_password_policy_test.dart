import 'package:flutter_test/flutter_test.dart';

import 'package:labedu/core/auth/cognito_password_policy.dart';

void main() {
  group('CognitoPasswordPolicy.validate', () {
    test('null password returns null (valid)', () {
      expect(CognitoPasswordPolicy.validate(null), isNull);
    });

    test('empty password returns null (valid — no validation on blank)', () {
      expect(CognitoPasswordPolicy.validate(''), isNull);
    });

    test('password shorter than 8 chars returns min8', () {
      expect(CognitoPasswordPolicy.validate('Ab1!'), 'min8');
    });

    test('password without uppercase returns upper', () {
      expect(CognitoPasswordPolicy.validate('abcdefg1!'), 'upper');
    });

    test('password without lowercase returns lower', () {
      expect(CognitoPasswordPolicy.validate('ABCDEFG1!'), 'lower');
    });

    test('password without digit returns digit', () {
      expect(CognitoPasswordPolicy.validate('Abcdefgh!'), 'digit');
    });

    test('password without symbol returns symbol', () {
      expect(CognitoPasswordPolicy.validate('Abcdefg1'), 'symbol');
    });

    test('valid password returns null', () {
      expect(CognitoPasswordPolicy.validate('Test123!'), isNull);
    });

    test('valid complex password returns null', () {
      expect(CognitoPasswordPolicy.validate('P@ssw0rd#2024'), isNull);
    });

    test('exactly 8 chars meeting all rules returns null', () {
      expect(CognitoPasswordPolicy.validate('Aa1!Aa1!'), isNull);
    });

    test('hint strings are non-empty', () {
      expect(CognitoPasswordPolicy.hintVi, isNotEmpty);
      expect(CognitoPasswordPolicy.hintEn, isNotEmpty);
    });
  });
}
