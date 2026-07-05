import 'package:kaouka/http/http_manager.dart';

Future<dynamic> getLikes(String reqId) async {
  final data = {
    'reqId': reqId,
  };
  final res = await get(data, "getLikes");
  return res['likes'];
}
