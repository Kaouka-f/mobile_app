import 'dart:io';

import 'package:kaouka/core/database.dart';
import 'package:kaouka/http/http_manager.dart';

Future<dynamic> sendMsg(
    String personId, String targetPersonId, String message, File file) async {
  String filepath = '';
  final data = {
    'personId': personId,
    'targetPersonId': targetPersonId,
    'message': message,
    // 'filename': file.path.isNotEmpty ? file.path.split('.').last : ''
  };
  // dynamic res = await sendFile(data, file, "sendMsg");
  dynamic res = await post(data, "sendMsg");
  if (res['media'] != null) {
    filepath = res['media'];
  }
  print(res);
  if (res['result'] == "true") {
    final DatabaseHelper databaseHelper = DatabaseHelper.instance;
    DateTime currentTimeUtc = DateTime.now().toUtc();
    String timestampIsoString = currentTimeUtc.toIso8601String();
    databaseHelper.insertMessage(
        timestampIsoString, message, targetPersonId, true, filepath);
    return {true, res['media']};
  } else if (res['result'] == "blocked") {
    return {false, "blocked"};
  }
  return {false, ""};
}
