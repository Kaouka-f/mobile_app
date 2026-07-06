import 'package:kaouka/http/http_manager.dart';

Future<dynamic> onConnection(String id) async {
  final data = {'id': id};
  final res = await post(data, "onConnection", withAuth: true);
  return res;
}
