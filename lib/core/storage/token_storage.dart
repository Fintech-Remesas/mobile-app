import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _keycloakUserIdKey = 'keycloak_user_id';
  static const _canOperateKey = 'can_operate';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> saveUserId(String userId) =>
      _storage.write(key: _userIdKey, value: userId);

  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<void> saveKeycloakUserId(String keycloakUserId) =>
      _storage.write(key: _keycloakUserIdKey, value: keycloakUserId);

  Future<String?> getKeycloakUserId() => _storage.read(key: _keycloakUserIdKey);

  Future<void> saveCanOperate(bool value) =>
      _storage.write(key: _canOperateKey, value: value.toString());

  Future<bool> getCanOperate() async {
    final value = await _storage.read(key: _canOperateKey);
    return value == 'true';
  }

  Future<void> clear() => _storage.deleteAll();
}
