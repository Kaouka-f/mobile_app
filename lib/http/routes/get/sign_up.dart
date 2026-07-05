import 'package:kaouka/http/http_manager.dart';

Future<bool> signUp(String password, String email) async {
  Map<String, dynamic> data = {'password': password, 'email': email};
  final res = await post(data, "signUp");
  print(res);
  // if (res.toString() == 'signed') {
  //   return false;
  // }
  return true;
}
