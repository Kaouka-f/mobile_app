import 'package:kaouka/http/http_manager.dart';
import 'package:kaouka/models/person.dart';

Future<Person> getInfos(String id) async {
  Person people;
  Map<String, dynamic> data = {'personid': id};
  final res = await get(data, "getInfos", withAuth: true);
  people = (Person(
    id: id,
    name: res['name'] ?? "undefined",
    img:
        res['img'] ?? "https://elaborium.site/proxy/stream/default/profile.jpg",
    scale: double.parse(res['scale'] ?? "0.0"),
    offsetX: double.parse(res['offsetX'] ?? "0.0"),
    offsetY: double.parse(res['offsetY'] ?? "0.0"),
    connected: res['connected'] == "true",
  ));
  return people;
}
