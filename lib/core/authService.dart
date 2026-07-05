import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final storage = FlutterSecureStorage();

  String? sessionToken;

  Future<String?> getPersistentToken() => storage.read(key: 'persistent_token');
  Future<void> setPersistentToken(String? value) async {
    if (value == null) {
      await storage.delete(key: 'persistent_token');
    } else {
      await storage.write(key: 'persistent_token', value: value);
    }
  }

  Future<void> logout() async {
    sessionToken = null;
    await storage.delete(key: 'persistent_token');
  }
}
