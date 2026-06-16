import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kaouka/database.dart';
import 'package:kaouka/pages/login/forgot_password.dart';
import 'package:kaouka/pages/login/signup_page.dart';
import 'package:kaouka/utils.dart';
import '../../components/custom_elevated_button.dart';
import '../../components/custom_text_field.dart';
import '../../http_manager.dart';
import '../../shared_data.dart';
import '../home_page.dart';
import '../../logging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

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
            // TODO: ajouter bouton apple connect, google connect
            CustomTextField(
              maxLength: 100,
              maxLines: 1,
              hintText: 'Email',
              onChanged: (value) {
                pseudo = value;
              },
            ),
            SizedBox(height: 16.0),
            CustomTextField(
              maxLength: 100,
              maxLines: 1,
              hintText: 'Mot de passe',
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
                  // TODO : ajouter password dans connect
                  res = await connect(pseudo);
                  if (!res) {
                    // TODO: get jwt from API
                    // String jwt = "${pseudo}_$password";
                    // await databaseHelper.updateDbId(jwt);
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
            const SizedBox(height: 16.0),
            CustomElevatedButton(
                text: 'Créer un nouveau compte',
                onPressed: () async {
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupPage(),
                    ),
                  );
                }),
            const SizedBox(height: 16.0),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: 'Mot de passe oublié ?',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
