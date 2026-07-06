import 'package:kaouka/core/authService.dart';
import 'package:kaouka/http/http_manager.dart';

Future<bool> connect(String pseudo, String password) async {
  Map<String, dynamic> data = {'email': pseudo, 'password': password};
  final res = await post(data, "connect");
  if (res["status"] == 'success') {
    AuthService authService = AuthService();
    authService.sessionToken = res['data']["session_token"];
    authService.setPersistentToken(res["data"]["persistent_token"]);
    return false;
  }
  return true;
}
