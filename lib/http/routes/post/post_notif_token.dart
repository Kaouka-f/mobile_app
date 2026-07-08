import 'package:kaouka/http/http_manager.dart';

Future<void> postNotifToken(String id, String notifToken) async {
  final data = {
    "id": id,
    "notifToken": notifToken,
  };
  final res = await post(data, "postNotifToken", withAuth: true);
  if (res["status"] != 'success') {
    // TODO: handle error
  }
}
