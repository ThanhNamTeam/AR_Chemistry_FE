import 'package:flutter_test/flutter_test.dart';
import 'package:labedu/domain/models/user_role.dart';

void main() {
  group('UserRole.label', () {
    test('student → "User"', () => expect(UserRole.student.label, 'User'));
    test('staff  → "Staff"', () => expect(UserRole.staff.label, 'Staff'));
    test('admin  → "Admin"', () => expect(UserRole.admin.label, 'Admin'));
    test('tất cả role đều có label không rỗng', () {
      for (final r in UserRole.values) {
        expect(r.label, isNotEmpty);
      }
    });
  });

  group('UserRole.name (dùng để lưu/đọc SharedPreferences)', () {
    test('name dạng lowercase', () {
      expect(UserRole.student.name, 'student');
      expect(UserRole.staff.name, 'staff');
      expect(UserRole.admin.name, 'admin');
    });

    test('round-trip: name → firstWhere → name', () {
      for (final role in UserRole.values) {
        final restored =
            UserRole.values.firstWhere((r) => r.name == role.name);
        expect(restored, role);
      }
    });
  });

  group('UserRole enum completeness', () {
    test('có đúng 3 role', () => expect(UserRole.values.length, 3));

    test('values chứa student, staff, admin', () {
      expect(
        UserRole.values,
        containsAll([UserRole.student, UserRole.staff, UserRole.admin]),
      );
    });
  });
}
