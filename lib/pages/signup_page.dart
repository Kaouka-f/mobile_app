import 'package:flutter/material.dart';
import '../components/custom_elevated_button.dart';
import '../components/custom_text_field.dart';
import '../http_manager.dart';
import '../shared_data.dart';
import 'home_page.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    String password = "";
    String email = "";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup Page'),
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
                email = value;
              },
            ),
            CustomTextField(
              maxLength: 100,
              maxLines: 1,
              hintText: 'Mot de passe',
              onChanged: (value) {
                password = value;
              },
            ),
            CustomElevatedButton(
              text: "S'inscrire",
              onPressed: () async {
                SharedData shared = SharedData();
                String id = shared.getId;
                bool res = true;
                if (email.isNotEmpty && password.isNotEmpty) {
                  res = await signUp(id, password, email);
                }
                if (!res) {
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
