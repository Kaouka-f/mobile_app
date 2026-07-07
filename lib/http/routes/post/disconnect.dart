import 'package:kaouka/core/authService.dart';
import 'package:kaouka/http/http_manager.dart';

Future<bool> disconnect() async {
  Map<String, dynamic> data = {};
  final res = await post(data, "disconnect", withAuth: true);
  if (res["status"] == 'sucess') {
    AuthService authService = AuthService();
    authService.logout();
    return false;
  }
  return true;
}
