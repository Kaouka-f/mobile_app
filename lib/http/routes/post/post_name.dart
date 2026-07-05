import 'package:kaouka/http/http_manager.dart';

Future<void> postName(String id, String name) async {
  final data = {
    "id": id,
    "name": name,
  };
  final res = post(data, "postName");
  if (res.toString() == "true") {
    // TODO: handle error
  }
}
