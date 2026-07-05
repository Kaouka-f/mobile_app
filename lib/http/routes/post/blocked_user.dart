import 'package:kaouka/http/http_manager.dart';

Future<dynamic> blockedUser(String id, String userId) async {
  final data = {'id': id, 'userId': userId};
  dynamic res = await post(data, "blockUser");
  return res['result'];
}
