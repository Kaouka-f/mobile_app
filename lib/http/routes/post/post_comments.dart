import 'dart:io';

import 'package:kaouka/http/http_manager.dart';

Future<dynamic> postComments(
    String id, String postId, String comment, File file) async {
  final data = {
    'id': id,
    'postId': postId,
    'comment': comment,
  };
  final res = await sendFile(data, file, "postComments");
  return res;
}
