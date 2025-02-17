import 'package:flutter/material.dart';
import '../theme.dart';

class LostConnectionPage extends StatelessWidget {
  const LostConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Problème de Réseau',
              style: TextStyle(fontSize: 18, color: maintenanceTextColor),
            ),
            CircularProgressIndicator(
              color: progressBarColor,
            ), // You can replace this with any loading indicator
          ],
        ),
      ),
    );
  }
}
