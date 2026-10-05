import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rahbar/data/storage/local_avatar_storage.dart';
import 'package:rahbar/application/auth/auth_controller.dart';
import 'package:path/path.dart' as path;

final localAvatarProvider = StateNotifierProvider<LocalAvatarNotifier, String?>((ref) {
  final userId = ref.watch(authControllerProvider.select((s) => s.profile?.id ?? s.profile?.phoneNumber));
  return LocalAvatarNotifier(ref.watch(localAvatarStorageProvider), userId);
});

class LocalAvatarNotifier extends StateNotifier<String?> {
  final LocalAvatarStorage _storage;
  final String? _userId;

  LocalAvatarNotifier(this._storage, this._userId) : super(null) {
    if (_userId != null) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_userId == null) return;
    state = await _storage.getAvatarPath(_userId!);
  }

  Future<void> updateAvatar(String originalPath) async {
    if (_userId == null) return;
    try {
      final File originalFile = File(originalPath);
      final directory = await getApplicationDocumentsDirectory();
      
      final userDir = Directory(path.join(directory.path, 'profile_avatars', _userId!));
      if (!await userDir.exists()) {
        await userDir.create(recursive: true);
      }

      final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}${path.extension(originalPath)}';
      final String persistentPath = path.join(userDir.path, fileName);
      
      // Copy to persistent storage
      await originalFile.copy(persistentPath);
      
      // Delete old avatar if it exists in docs dir
      if (state != null && state!.startsWith(directory.path)) {
        try {
          final oldFile = File(state!);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (_) {}
      }

      state = persistentPath;
      await _storage.saveAvatarPath(_userId!, persistentPath);
    } catch (e) {
      // Fallback to original if copy fails
      state = originalPath;
      await _storage.saveAvatarPath(_userId!, originalPath);
    }
  }

  Future<void> removeAvatar() async {
    if (_userId == null) return;
    if (state != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        if (state!.startsWith(directory.path)) {
          final file = File(state!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      } catch (_) {}
    }
    state = null;
    await _storage.removeAvatarPath(_userId!);
  }
}
