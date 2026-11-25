import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'authToken';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } on PlatformException {
      // The keystore key is gone (restored backup, removed lock screen):
      // the old token is unreadable, so start clean.
      await _storage.deleteAll();
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
