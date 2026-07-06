import 'package:kaouka/http/http_manager.dart';

Future<dynamic> deleteMsg(String id, String media) async {
  final data = {'id': id, 'media': media};
  dynamic res = await post(data, "deleteMsg", withAuth: true);
  return res['result'];
}
