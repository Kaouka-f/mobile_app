import 'package:kaouka/http/http_manager.dart';

Future<dynamic> paying(String id, String payId) async {
  final data = {
    'id': id,
    'payId': payId,
  };
  final res = post(data, "paying", withAuth: true);
  return res;
}
