import 'dart:io';

import 'package:kaouka/http/http_manager.dart';

Future<String> postPP(String id, String imgUrl) async {
  final data = {
    "id": id,
  };
  return await sendFile(data, File(imgUrl), "postPP");
}
