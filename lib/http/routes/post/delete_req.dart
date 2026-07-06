import 'package:kaouka/http/http_manager.dart';

Future<dynamic> deleteReq(String id, String reqId) async {
  final data = {
    'id': id,
    'reqId': reqId,
  };
  final res = post(data, "deleteReq", withAuth: true);
  return res;
}
