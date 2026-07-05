import 'package:kaouka/http/http_manager.dart';

Future<void> postNotifToken(String id, String notifToken) async {
  final data = {
    "id": id,
    "notifToken": notifToken,
  };
  final res = post(data, "postNotifToken");
  if (res.toString() == "true") {
    // TODO: handle error
  }
}
