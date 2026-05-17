import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AvatarStorageService {
  static Future<String> saveAvatar(String sourcePath, String email) async {
    final dir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory(p.join(dir.path, 'avatars'));
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }

    final ext = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final safeEmail = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final destPath = p.join(avatarsDir.path, 'avatar_$safeEmail$ext');

    await File(sourcePath).copy(destPath);
    return destPath;
  }

  static bool avatarFileExists(String? path) {
    if (path == null || path.isEmpty) return false;
    return File(path).existsSync();
  }
}
