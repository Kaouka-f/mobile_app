import 'package:kaouka/http/http_manager.dart';

Future<dynamic> postLocation(String id, double long, double lat) async {
  final data = {'id': id, 'long': long, 'lat': lat};
  dynamic res = await post(data, "postLocation", withAuth: true);
  return res['result'];
}
