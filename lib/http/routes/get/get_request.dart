import 'package:flutter/foundation.dart';
import 'package:kaouka/http/http_manager.dart';
import 'package:kaouka/models/person.dart';
import 'package:kaouka/models/request.dart';

Future<ReqPerson?> getRequest(String reqId) async {
  ReqPerson request;
  final data = {
    'reqId': reqId,
  };
  final res = await get(data, "getRequest");
  try {
    if (res != null) {
      request = ReqPerson(
          person: Person(
            id: res['id'].toString(),
            name: res['name'] ?? "undefined",
            img: res['picture'] != ""
                ? res['picture'].toString()
                : "https://elaborium.site/proxy/stream/default/profile.jpg",
            scale: double.parse(res['scale'] ?? "1.0"),
            offsetX: double.parse(res['offsetX'] ?? "0.0"),
            offsetY: double.parse(res['offsetY'] ?? "0.0"),
            connected: res['connected'] == "true",
          ),
          request: Request.fromJson(res),
          dist: "");
    } else {
      return null;
    }
  } catch (e) {
    if (kDebugMode) print('get req error : $e');
    return null;
  }
  return request;
}
