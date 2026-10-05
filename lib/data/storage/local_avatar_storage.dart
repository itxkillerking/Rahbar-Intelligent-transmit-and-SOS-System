import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localAvatarStorageProvider = Provider<LocalAvatarStorage>((ref) {
  return LocalAvatarStorage();
});

class LocalAvatarStorage {
  String _avatarKey(String userId) => 'local_avatar_$userId';

  Future<void> saveAvatarPath(String userId, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarKey(userId), path);
  }

  Future<String?> getAvatarPath(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_avatarKey(userId));
  }

  Future<void> removeAvatarPath(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_avatarKey(userId));
  }
}
