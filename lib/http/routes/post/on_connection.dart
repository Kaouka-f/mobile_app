import 'package:kaouka/http/http_manager.dart';

Future<dynamic> onConnection(String id) async {
  final res = await post({}, "onConnection", withAuth: true);
  return res;
}
