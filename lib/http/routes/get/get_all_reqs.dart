import 'package:kaouka/http/http_manager.dart';
import 'package:kaouka/models/person.dart';
import 'package:kaouka/models/request.dart';

Future<List<ReqPerson>> getAllReqs(Person person, String lastReqId) async {
  List<ReqPerson> posts = [];
  final data = {'id': person.id, 'lastReqId': lastReqId};
  final res = await get(data, "getAllReqs");
  if (res != null) {
    res.forEach((key, value) {
      Request req = Request.fromJson(value);
      posts.add(ReqPerson(person: person, request: req, dist: ""));
    });
  }
  return posts;
}
