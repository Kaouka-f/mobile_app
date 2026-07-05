import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kaouka/core/database.dart';
import 'package:kaouka/pages/login/login_page.dart';
import 'package:kaouka/pages/login/signup_page.dart';
import 'package:kaouka/utils.dart';
import '../../components/custom_elevated_button.dart';
import '../../components/custom_text_field.dart';
import '../../core/shared_data.dart';
import '../home_page.dart';
import '../../core/logging.dart';

class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    String pseudo = "";
    String password = "";
    final DatabaseHelper databaseHelper = DatabaseHelper.instance;

    void _signInWithGoogle() {
      // TODO: GoogleSignIn().signIn();
      print("Google Sign-In not implemented yet");
    }

    void _signInWithApple() {
      // TODO: SignInWithApple.getAppleIDCredential(...)
      print("Apple Sign-In not implemented yet");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Connexion'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TODO: ajouter bouton apple connect, google connect
            // ── Bouton Google ──────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _signInWithGoogle,
                icon: const FaIcon(
                  FontAwesomeIcons.google,
                  color: Color(0xFF4285F4),
                  size: 20,
                ),
                label: const Text(
                  'Continuer avec Google',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.black, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Bouton Apple ───────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _signInWithApple,
                icon: const FaIcon(
                  FontAwesomeIcons.apple,
                  color: Colors.white,
                  size: 22,
                ),
                label: const Text(
                  'Continuer avec Apple',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            CustomElevatedButton(
                text: 'Email',
                onPressed: () async {
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
