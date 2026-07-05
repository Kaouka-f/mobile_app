import 'package:kaouka/http/http_manager.dart';

Future<dynamic> signalReq(String id, String reqId) async {
  final data = {
    'id': id,
    'reqId': reqId,
  };
  final res = post(data, "signal_request");
  return res;
}
