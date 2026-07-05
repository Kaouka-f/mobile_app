import 'dart:io';

import 'package:kaouka/http/http_manager.dart';

Future<dynamic> postRequest(String id, String request, File file) async {
  final data = {
    "id": id,
    "request": request,
  };
  dynamic res = await sendFile(data, file, "postReq");
  return res;
}
