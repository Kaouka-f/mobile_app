import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kaouka/database.dart';
import 'package:kaouka/utils.dart';
import '../components/custom_elevated_button.dart';
import '../components/custom_text_field.dart';
import '../http_manager.dart';
import '../shared_data.dart';
import 'home_page.dart';
import '../logging.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    String pseudo = "";
    String password = "";
    final DatabaseHelper databaseHelper = DatabaseHelper.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              maxLength: 100,
              maxLines: 1,
              hintText: 'ID1',
              onChanged: (value) {
                pseudo = value;
              },
            ),
            CustomTextField(
              maxLength: 100,
              maxLines: 1,
              hintText: 'ID2',
              onChanged: (value) {
                password = value;
              },
            ),
            const SizedBox(height: 16.0),
            CustomElevatedButton(
              text: 'Se connecter',
              onPressed: () async {
                bool res = false;
                if (pseudo.isNotEmpty && password.isNotEmpty) {
                  SharedData shared = SharedData();
                  LoggerManager.logInfo(pseudo);
                  LoggerManager.logInfo(password);
                  String id = "${pseudo}_$password";
                  String encodeid = encodeId(id);
                  res = await connect(encodeid);
                  if (!res) {
                    await databaseHelper.updateDbId(id);
                    shared.setId = encodeId(id);
                    showPopUp(
                        // ignore: use_build_context_synchronously
                        context,
                        "Connexion",
                        "Connexion établi",
                        () => ());
                    await FirebaseMessaging.instance.deleteToken();
                    String? token = await FirebaseMessaging.instance.getToken();
                    print(token);
                    shared.setNotifToken = token!;
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  } else {
                    showPopUp(
                        // ignore: use_build_context_synchronously
                        context,
                        "Connexion",
                        "compte introuvable",
                        () => ());
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
