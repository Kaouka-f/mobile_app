import 'package:kaouka/http/http_manager.dart';

Future<void> visible(String id, String value) async {
  final data = {'id': id, 'value': value};
  final res = await post(data, "visible", withAuth: true);
  if (res["status"] != 'success') {
    // TODO: handle error
  }
}
