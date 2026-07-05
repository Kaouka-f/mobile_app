import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kaouka/core/database.dart';
import 'package:kaouka/pages/login/signup_page.dart';
import 'package:kaouka/utils.dart';
import '../../components/custom_elevated_button.dart';
import '../../components/custom_text_field.dart';
import '../../core/shared_data.dart';
import '../home_page.dart';
import '../../core/logging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

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
              hintText: 'Email',
              onChanged: (value) {
                pseudo = value;
              },
            ),
            SizedBox(height: 16.0),
            CustomElevatedButton(
              text: 'Reinitialiser le mot de passe',
              onPressed: () {
                // TODO : send a link to reset password
              },
            ),
          ],
        ),
      ),
    );
  }
}
