import 'package:flutter/material.dart';
import '../theme.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'server en maintenance temps estimé à',
              style: TextStyle(fontSize: 18, color: maintenanceTextColor),
            ),
            Text(
              '10 min',
              style: TextStyle(fontSize: 18, color: maintenanceTextColor),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: progressBarColor,
            ), // You can replace this with any loading indicator
          ],
        ),
      ),
    );
  }
}
