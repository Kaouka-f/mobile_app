import 'package:kaouka/http/http_manager.dart';

// Future<dynamic> deleteAccount(String id, String email, String password) async {}
Future<dynamic> deleteAcnt(String id) async {
  final data = {
    'id': id,
  };
  final res = post(data, "deleteAccount");
  return res;
}
