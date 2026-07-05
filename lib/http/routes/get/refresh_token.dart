import 'package:kaouka/http/http_manager.dart';

Future<bool> refreshToken(String persistentToken) async {
  Map<String, dynamic> data = {'persistent_token': persistentToken};
  final res = await post(data, "refreshToken");
  if (res["session_token"] != null) {
    return false;
  }
  return true;
}
