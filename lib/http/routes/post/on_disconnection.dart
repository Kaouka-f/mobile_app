import 'package:kaouka/http/http_manager.dart';

Future<dynamic> onDisconnection(String id) async {
  final res = await post({}, "onDisconnection", withAuth: true);
  return res;
}
