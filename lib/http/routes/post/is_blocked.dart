import 'package:kaouka/http/http_manager.dart';

Future<dynamic> isBlocked(String id, String userId) async {
  final data = {'id': id, 'userId': userId};
  dynamic res = await get(data, "isBlocked");
  return res['result'];
}
