import 'package:kaouka/http/http_manager.dart';

Future<dynamic> onDisconnection(String id) async {
  final data = {'id': id};
  final res = await post(data, "onDisconnection", withAuth: true);
  return res;
}
