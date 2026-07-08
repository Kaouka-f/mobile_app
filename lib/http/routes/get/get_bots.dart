import 'package:kaouka/http/http_manager.dart';

Future<dynamic> getBots() async {
  final data = {'password': 'zigzag'};
  return await get(data, "getBots", withAuth: true);
}
