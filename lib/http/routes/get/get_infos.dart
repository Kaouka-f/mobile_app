import 'package:kaouka/http/http_manager.dart';
import 'package:kaouka/models/person.dart';

Future<Person?> getInfos(String id) async {
  Person people;
  Map<String, dynamic> data = {'personid': id};
  final res = await get(data, "getInfos", withAuth: true);
  if (res["status"] == 'success') {
    people = (Person(
      id: id,
      name: res['data']['name'] ?? "undefined",
      img: res['data']['img'] ??
          "https://elaborium.site/proxy/stream/default/profile.jpg",
      scale: double.parse(res['data']['scale'] ?? "0.0"),
      offsetX: double.parse(res['data']['offsetX'] ?? "0.0"),
      offsetY: double.parse(res['data']['offsetY'] ?? "0.0"),
      connected: res['data']['connected'] == "true",
    ));
    return people;
  } else {
    return null;
  }
}
