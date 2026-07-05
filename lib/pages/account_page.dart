import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kaouka/components/custom_elevated_button.dart';
import 'package:kaouka/core/database.dart';
import 'package:kaouka/http/routes/get/retrieve_id.dart';
import 'package:kaouka/http/routes/post/delete_acnt.dart';

import 'package:kaouka/pages/login/login_page.dart';
import 'package:kaouka/core/shared_data.dart';
import 'package:kaouka/utils.dart';
import 'package:restart_app/restart_app.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    initSharedPref();
    super.initState();
  }

  late String id;
  SharedData shared = SharedData();
  String deleteCacheTitle = "Supprimer tous les messages";
  String deleteCacheMessage =
      "En supprimant le cache, tous les messages et contact de l'application seront supprimé. Etes-vous sur de vouloir supprimer le cache ?";

  void initSharedPref() async {
    String? encodedid = shared.getId;
    setState(() {
      id = encodedid;
    });
  }

  deleteAccount() async {
    deleteAcnt(id);
    await FirebaseMessaging.instance.deleteToken();
    String? token = await FirebaseMessaging.instance.getToken();
    shared.setNotifToken = token!;
    final DatabaseHelper databaseHelper = DatabaseHelper.instance;
    databaseHelper.purgeApp();
    shared.clear();
    shared.init();
    // Bug: on delete account probleme
    dynamic idObj = await retrieveId();
    id = "${idObj['id']}_${idObj['privateId']}";
    await databaseHelper.insertDbId(id);
    shared.setId = encodeId(id);
    Restart.restartApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Compte"),
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
                padding: const EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: () {
                    copyToClipboard(context,
                        decodeId1(id)); // Pass the variable to the function
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("id1: "),
                      Text(style: const TextStyle(fontSize: 12), decodeId1(id)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: () {
                    copyToClipboard(context,
                        decodeId3(id)); // Pass the variable to the function
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("id2: "),
                      Text(
                        style: const TextStyle(fontSize: 12),
                        decodeId3(id),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            CustomElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              text: 'Se Connecter',
            ),
            const SizedBox(height: 20.0),
            CustomElevatedButton(
              onPressed: () {
                showPopUp(context, deleteCacheTitle, deleteCacheMessage,
                    deleteAccount,
                    isDismissible: true);
              },
              text: 'Delete Account',
            ),
          ]),
        )));
  }
}
