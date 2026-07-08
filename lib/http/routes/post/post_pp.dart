import 'dart:io';

import 'package:kaouka/http/http_manager.dart';

Future<String> postPP(String id, String imgUrl) async {
  return await sendFile({}, File(imgUrl), "postPP");
}
