import 'package:flutter/material.dart';
import 'package:kaouka/components/kavatar.dart';
import 'package:kaouka/http/routes/get/get_infos.dart';
import 'package:kaouka/models/person.dart';
import 'package:kaouka/core/shared_data.dart';
import 'package:kaouka/models/bot.dart';
import 'package:kaouka/core/database.dart';

import 'package:kaouka/utils.dart';
import 'package:restart_app/restart_app.dart';

class UserMenu extends StatefulWidget {
  final Function toggleMenu;
  const UserMenu({super.key, required this.toggleMenu});
  @override
  State<UserMenu> createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  SharedData sharedData = SharedData();
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  String hintText = 'undefined';

  List<Bot> users = [];
  // final List<String> users = List.generate(50, (index) => 'User ${index + 1}');

  getUsers() async {
    List<Bot> tmpUsers = await databaseHelper.getBots();
    for (var user in tmpUsers) {
      Person? infos = await getInfos(user.id1);
      if (infos != null) {
        user.name = infos.name;
        user.pp = infos.img;
      }
    }
    setState(() {
      users = tmpUsers;
    });
  }

  addUser() async {
    // dynamic idObj = await retrieveId();
    // TODO: set bot true
    // await databaseHelper
    //     .insertBot(Bot(id1: idObj['id'], id2: idObj['privateId']));
    getUsers();
  }

  selectUser(String id1, String id2) async {
    String id = "${id1}_$id2";
    sharedData.setId = encodeId(id);
    // Restart.restartApp(); // reastarting app cause db damage
    // TODO: get user infos and set it in shared
    final infos = await getInfos(id1);
    if (infos != null) {
      sharedData.name = infos.name;
      sharedData.imageUrl = infos.img;
      sharedData.imageOffset = Offset(infos.offsetX, infos.offsetY);
      sharedData.imageScale = infos.scale;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${infos.name} selected"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users Menu')),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            widget.toggleMenu();
          }
        },
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 150,
                color: Colors.black,
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(children: [
                      ElevatedButton(
                          onPressed: () {
                            addUser();
                          },
                          child: Text("add user")),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: users.length,
                          itemBuilder: (BuildContext context, int index) {
                            final user = users[index];
                            return GestureDetector(
                              onTap: () async {
                                await selectUser(user.id1, user.id2);
                              },
                              child: ListTile(
                                title: Text(user.name),
                                leading: KAvatar(
                                  imageAssetPath: user.pp,
                                  scale: 1.0,
                                  offset: Offset(0.0, 0.0),
                                  radius: 15,
                                  borderSize: 0,
                                  connected: false,
                                ),
                              ),
                            );
                          }),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
