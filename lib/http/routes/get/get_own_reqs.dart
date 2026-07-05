import 'package:flutter/foundation.dart';
import 'package:kaouka/http/http_manager.dart';
import 'package:kaouka/models/person.dart';
import 'package:kaouka/models/request.dart';
import 'package:kaouka/core/shared_data.dart';
import 'package:kaouka/utils.dart';

Future<dynamic> getOwnReqs(String id, String lastReqId) async {
  SharedData shared = SharedData();
  List<ReqPerson> requests = [];
  final data = {
    'id': id,
    'lastReqId': lastReqId,
  };
  final res = await get(data, "getOwnReqs");
  try {
    if (res != null) {
      res.forEach((key, value) {
        requests.add(ReqPerson(
          person: Person(
            id: decodeId1(shared.id),
            name: shared.name,
            img: shared.imageUrl,
            scale: shared.imageScale,
            offsetX: shared.imageOffset.dx,
            offsetY: shared.imageOffset.dy,
            connected: false,
          ),
          request: Request.fromJson(value),
          dist: '',
        ));
      });
    }
  } catch (e) {
    if (kDebugMode) print(e);
  }
  // requests = Request.jsonToList(res);
  return requests;
}
