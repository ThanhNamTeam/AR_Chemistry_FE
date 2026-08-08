import 'package:flutter_test/flutter_test.dart';
import 'package:labedu/core/storage/role_session_service.dart';
import 'package:labedu/domain/models/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late RoleSessionService svc;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    svc = RoleSessionService();
  });

  // ── save / load ───────────────────────────────────────────────────────────

  group('save / load', () {
    test('lưu student + email, đọc lại đúng', () async {
      await svc.save(UserRole.student, 'hs@school.vn');
      final session = await svc.load();
      expect(session?.role, UserRole.student);
      expect(session?.email, 'hs@school.vn');
    });

    test('lưu staff, đọc lại đúng', () async {
      await svc.save(UserRole.staff, 'staff@school.vn');
      final session = await svc.load();
      expect(session?.role, UserRole.staff);
    });

    test('lưu admin, đọc lại đúng', () async {
      await svc.save(UserRole.admin, 'admin@school.vn');
      final session = await svc.load();
      expect(session?.role, UserRole.admin);
    });

    test('load khi chưa lưu → null', () async {
      expect(await svc.load(), isNull);
    });

    test('ghi đè: save 2 lần → đọc lần 2', () async {
      await svc.save(UserRole.student, 'a@x.vn');
      await svc.save(UserRole.admin, 'b@x.vn');
      final session = await svc.load();
      expect(session?.role, UserRole.admin);
      expect(session?.email, 'b@x.vn');
    });
  });

  // ── clear ─────────────────────────────────────────────────────────────────

  group('clear', () {
    test('clear sau save → load = null', () async {
      await svc.save(UserRole.student, 'x@x.vn');
      await svc.clear();
      expect(await svc.load(), isNull);
    });

    test('clear khi chưa lưu → không crash', () async {
      await expectLater(svc.clear(), completes);
    });
  });

  // ── saveProfile / getProfile ──────────────────────────────────────────────

  group('saveProfile / getProfile', () {
    test('round-trip profile student', () async {
      await svc.saveProfile(UserRole.student, {'displayName': 'Học sinh', 'score': 90});
      final loaded = await svc.getProfile(UserRole.student);
      expect(loaded?['displayName'], 'Học sinh');
      expect(loaded?['score'], 90);
    });

    test('getProfile trước khi lưu → null', () async {
      expect(await svc.getProfile(UserRole.student), isNull);
    });

    test('profile của mỗi role độc lập nhau', () async {
      await svc.saveProfile(UserRole.student, {'name': 'Student A'});
      await svc.saveProfile(UserRole.staff, {'name': 'Staff B'});

      final studentProfile = await svc.getProfile(UserRole.student);
      final staffProfile = await svc.getProfile(UserRole.staff);

      expect(studentProfile?['name'], 'Student A');
      expect(staffProfile?['name'], 'Staff B');
    });

    test('getProfile role chưa lưu → null', () async {
      await svc.saveProfile(UserRole.student, {'x': 1});
      expect(await svc.getProfile(UserRole.admin), isNull);
    });
  });

  // ── roleName không hợp lệ trong prefs ────────────────────────────────────

  group('edge case – roleName không hợp lệ', () {
    test('roleName lạ trong prefs → fallback student', () async {
      SharedPreferences.setMockInitialValues({
        'session_role': 'invalid_role',
        'session_role_email': 'x@x.com',
      });
      final session = await svc.load();
      expect(session?.role, UserRole.student);
      expect(session?.email, 'x@x.com');
    });
  });
}
