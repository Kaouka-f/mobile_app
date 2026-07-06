import 'package:kaouka/http/http_manager.dart';

Future<bool> isPayed(String id) async {
  Map<String, dynamic> data = {'id': id};
  final res = await get(data, "isPayed", withAuth: true);
  if (res == 'payed') {
    return false;
  }
  return true;
}
