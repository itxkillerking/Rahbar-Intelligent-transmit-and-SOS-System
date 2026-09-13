import '../../domain/services/storage_service.dart';

class MockStorageService implements StorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return _storage[key];
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }
}
