import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaouka/http/http_manager.dart';

Future<bool> connect(String pseudo, String password) async {
  Map<String, dynamic> data = {'email': pseudo, 'password': password};
  final res = await post(data, "connect");
  if (res["connection"] == 'sucess') {
    final storage = FlutterSecureStorage();
    await storage.write(
        key: 'persistent_token', value: res["persistent_token"]);
    await storage.write(key: 'session_token', value: res["persistent_token"]);
    return false;
  }
  return true;
}
