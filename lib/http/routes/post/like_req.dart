import 'package:kaouka/http/http_manager.dart';

Future<dynamic> likeReq(String id, String reqId) async {
  final data = {'id': id, 'reqId': reqId};
  final res = await post(data, "likeReq", withAuth: true);
  return res;
}
