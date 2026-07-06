import 'package:kaouka/http/http_manager.dart';
import 'package:kaouka/core/authService.dart';

Future<bool> refreshToken(String persistentToken) async {
  Map<String, dynamic> data = {'persistent_token': persistentToken};
  final res = await post(data, "refreshToken");
  if (res["status"] == "success") {
    AuthService authService = AuthService();
    authService.sessionToken = res["data"]["session_token"];
    return false;
  }
  return true;
}
