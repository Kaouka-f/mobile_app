import 'package:kaouka/http/http_manager.dart';

Future<dynamic> getFeed(String id) async {
  final data = {
    'id': id,
  };
  final res = await get(data, "getFeed");
  return res;
}
