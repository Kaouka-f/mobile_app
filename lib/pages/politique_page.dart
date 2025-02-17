import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kaouka/components/cgu_.dart';
import 'package:kaouka/components/custom_elevated_button.dart';
import 'package:kaouka/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class PolitiquePage extends StatefulWidget {
  const PolitiquePage({super.key});

  @override
  State<PolitiquePage> createState() => _PolitiquePageState();
}

class _PolitiquePageState extends State<PolitiquePage> {
  @override
  void initState() {
    super.initState();
  }

  void _contactByDiscord() async {
    const String discordUrl = 'https://discord.gg/gBz3Eygx';
    if (await canLaunch(discordUrl)) {
      await launch(discordUrl);
    } else {
      // Handle the case where the Discord app or browser cannot be opened
      if (kDebugMode) {
        print('Could not launch Discord');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Politique"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    showPopUp(context, generalConditionTitle,
                        generalConditionMessage, () => ());
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Condition General"),
                      // Text(style: const TextStyle(fontSize: 12), decodeId(id)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            CustomElevatedButton(
              onPressed: _contactByDiscord,
              text: 'Contactez-nous',
            ),
          ]),
        ),
      ),
    );
  }
}
