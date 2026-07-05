import 'package:flutter/material.dart';
import 'package:kaouka/http/routes/get/sign_up.dart';
import '../../components/custom_elevated_button.dart';
import '../../components/custom_text_field.dart';
import '../../core/shared_data.dart';
import '../home_page.dart';

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
            const SizedBox(height: 16.0),
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
              text: "S'inscrire",
              onPressed: () async {
                bool res = true;
                print("signup with email: $email and password: $password");
                if (email.isNotEmpty && password.isNotEmpty) {
                  res = await signUp(password, email);
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
