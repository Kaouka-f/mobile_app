import 'package:kaouka/http/http_manager.dart';

Future<bool> updateReq(String id, String reqId, String newReq) async {
  final data = {
    'id': id,
    'reqId': reqId,
    'newReq': newReq,
  };
  final res = await post(data, "updateReq");
  return res;
}
