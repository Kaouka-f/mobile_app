import 'package:kaouka/models/request.dart';

class ReqPerson {
  final Person person;
  final Request request;
  final String dist;
  ReqPerson({
    required this.person,
    required this.request,
    required this.dist,
  });
}

class Person {
  final String id;
  final String name;
  final String img;
  final double scale;
  final double offsetX;
  final double offsetY;
  final bool connected;
  Person({
    required this.connected,
    required this.id,
    required this.name,
    this.img = "https://elaborium.site/proxy/stream/default/profile.jpg",
    this.scale = 1,
    required this.offsetX,
    required this.offsetY,
  });
}
