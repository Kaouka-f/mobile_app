import 'package:kaouka/http/http_manager.dart';

Future<dynamic> retrieveId() async {
  Map<String, dynamic> data = {};
  final res = await get(data, "getId");
  return {"id": res['id'], "privateId": res['privateid']};
}
