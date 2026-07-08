import 'package:kaouka/http/http_manager.dart';

Future<void> postName(String id, String name) async {
  final data = {
    "id": id,
    "name": name,
  };
  final res = await post(data, "postName", withAuth: true);
  if (res["status"] != 'success') {
    // TODO: handle error
  }
}
