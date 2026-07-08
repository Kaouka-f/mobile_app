import 'package:kaouka/http/http_manager.dart';

Future<void> postPPSetting(
    String id, double scale, double offsetX, double offsetY) async {
  final data = {
    "id": id,
    "scale": scale.toString(),
    "offsetX": offsetX.toString(),
    "offsetY": offsetY.toString(),
  };
  final res = await post(data, "postPPSetting", withAuth: true);
  if (res["status"] != 'success') {
    // TODO: handle error
  }
}
