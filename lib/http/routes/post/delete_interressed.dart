import 'package:kaouka/http/http_manager.dart';

Future<dynamic> deleteInterressed(String id, String reqId) async {
  final data = {
    'id': id,
    'reqId': reqId,
  };
  final res = post(data, "deleteInterressed");
  return res;
}
