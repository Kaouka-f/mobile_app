import 'package:kaouka/http/http_manager.dart';

Future<dynamic> createBot(
    String id,
    String privateId,
    String name,
    String img,
    double scale,
    double offsetX,
    double offsetY,
    double longitude,
    double latitude) async {
  final data = {
    'id': id,
    'privateId': privateId,
    'name': name,
    'imgUrl': img,
    'scale': scale,
    'offsetX': offsetX,
    'offsetY': offsetY,
    'lng': longitude,
    'lat': latitude,
    'password': 'zigzag'
  };
  return await post(data, "createBot", withAuth: true);
}
