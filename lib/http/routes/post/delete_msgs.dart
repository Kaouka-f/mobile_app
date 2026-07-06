import 'package:kaouka/http/http_manager.dart';

Future<void> deleteMsgs(String id) async {
  final data = {'id': id};
  await post(data, "deleteMsgs", withAuth: true);
}
