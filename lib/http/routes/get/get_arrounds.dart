import 'package:flutter/foundation.dart';
import 'package:kaouka/http/http_manager.dart';
import 'package:kaouka/models/person.dart';
import 'package:kaouka/models/request.dart';

Future<List<ReqPerson>> getArrounds(String id, double long, double lat) async {
  String longStr = long.toString();
  String latStr = lat.toString();
  Map<String, dynamic> data = {'id': id, 'long': longStr, 'lat': latStr};
  final res = await get(data, "getArrounds");
  List<ReqPerson> requests = [];
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
          request: Request.fromJson(value['requests']),
          dist: value['distance'].toString(),
        ));
      });
    }
  } catch (e) {
    if (kDebugMode) print(e);
  }
  return requests;
}
