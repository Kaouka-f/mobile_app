import 'package:flutter/foundation.dart';
import 'package:kaouka/http/http_manager.dart';
import 'package:kaouka/models/person.dart';
import 'package:kaouka/models/request.dart';

Future<List<ReqPerson>> getComments(String id, String lastReqId) async {
  List<ReqPerson> requests = [];
  Map<String, dynamic> data = {'id': id, 'lastReqId': lastReqId};
  final res = await get(data, "getComments");
  try {
    if (res != null) {
      res.forEach((key, value) {
        requests.add(ReqPerson(
          person: Person(
            id: value['id'].toString(),
            name: value['name'] ?? "undefined",
            img: value['picture'] != ""
                ? value['picture'].toString()
                : "https://elaborium.site/proxy/stream/default/profile.jpg",
            scale: double.parse(value['scale'] ?? "1.0"),
            offsetX: double.parse(value['offsetX'] ?? "0.0"),
            offsetY: double.parse(value['offsetY'] ?? "0.0"),
            connected: value['connected'] == "true",
          ),
          request: Request.fromJson(value),
          dist: value['distance'].toString(),
        ));
      });
    }
  } catch (e) {
    if (kDebugMode) print(e);
  }
  return requests;
}
