import 'package:kaouka/components/kavatar.dart';
import 'package:kaouka/http/routes/get/get_infos.dart';
import 'package:kaouka/http/routes/post/blocked_user.dart';
import 'package:kaouka/http/routes/post/is_blocked.dart';
import 'package:kaouka/models/contact.dart';

import 'package:kaouka/notifiers/message_notifier.dart';
import 'package:kaouka/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:kaouka/core/shared_data.dart';
import '../core/database.dart';
import '../utils.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<Contact> contacts = [];
  Map<String, int> unreadMsgs = {};
  final MessageNotifier newMessageNotifier = MessageNotifier();
  SharedData sharedData = SharedData();
  String id = "";
  int? revealedIndex;
  bool blocked = false;
  bool blockedLoad = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    MessageNotifier.instance.removeListener(getUnreadMsg);
    super.dispose();
  }

  void init() async {
    id = sharedData.getId;
    databaseHelper.getContact().then((value) async {
      for (var contactId in value) {
        if (contactId != decodeId1(id)) {
          final pInfos = await getInfos(contactId);
          setState(() {
            contacts.add(Contact(
                id: contactId,
                name: pInfos.name,
                dist: '',
                img: pInfos.img,
                scale: pInfos.scale,
                offsetX: pInfos.offsetX,
                offsetY: pInfos.offsetY,
                connected: pInfos.connected));
          });
        }
      }
    });
    MessageNotifier.instance.addListener(getUnreadMsg);
    await getUnreadMsg();
    await handleMsg();
  }

  getUnreadMsg() async {
    List<Map<String, dynamic>> tmp = await databaseHelper.getUnreadMessages();
    List<String> toDelete = [];
    if (tmp.isNotEmpty) {
      setState(() {
        unreadMsgs.clear();
      });

      for (var element in tmp) {
        toDelete.add(element['personId']);
        setState(() {
          if (unreadMsgs.containsKey(element['personId'])) {
            unreadMsgs[element['personId']] =
                unreadMsgs[element['personId']]! + 1;
          } else {
            unreadMsgs[element['personId']] = 1;
          }
        });
      }
    }
    for (var contact in contacts) {
      if (!toDelete.contains(contact.id)) {
        setState(() {
          unreadMsgs.remove(contact.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: contacts.length,
            itemBuilder: (BuildContext context, int index) {
              final contact = contacts[index];
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              id: contacts[index].id,
                              navBack: getUnreadMsg,
                            ),
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Dismissible(
                        key: Key(
                            contacts[index].name), // Unique key for each item
                        direction: revealedIndex == index
                            ? DismissDirection
                                .startToEnd // Swipe right to hide delete
                            : DismissDirection
                                .endToStart, // Swipe left to show delete
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            // Swipe left to reveal delete button
                            setState(() {
                              blockedLoad = true;
                            });
                            dynamic res =
                                await isBlocked(id, contacts[index].id);
                            setState(() {
                              if (res == "true") blocked = true;
                              revealedIndex = index;
                              blockedLoad = false;
                            });
                          } else if (direction == DismissDirection.startToEnd) {
                            // Swipe right to hide delete button
                            setState(() {
                              blocked = false;
                              revealedIndex = null;
                            });
                          }
                          return false; // Prevent dismissal
                        },
                        child: ListTile(
                          titleAlignment: ListTileTitleAlignment.center,
                          title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              verticalDirection: VerticalDirection.up,
                              children: [
                                Text(
                                  contact.name,
                                ),
                                revealedIndex == index
                                    ? Row(children: [
                                        GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              blockedLoad = true;
                                            });
                                            dynamic res = await blockedUser(
                                                id, contacts[index].id);
                                            dynamic res2 = await isBlocked(
                                                id, contacts[index].id);
                                            if (res2 == "true")
                                              blocked = true;
                                            else
                                              blocked = false;
                                            if (res == 'true') {
                                              setState(() {
                                                blockedLoad = false;
                                              });
                                            }
                                          },
                                          child: blockedLoad
                                              ? const RefreshProgressIndicator(
                                                  backgroundColor: Colors.black,
                                                  color: Colors.white,
                                                )
                                              : Column(children: [
                                                  Icon(
                                                    Icons.block,
                                                    color: blocked
                                                        ? Colors.blue
                                                        : Colors.white,
                                                    size: 30,
                                                  ),
                                                  Text(
                                                    !blocked
                                                        ? 'bloquer'
                                                        : 'débloquer',
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  )
                                                ]),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              databaseHelper.deleteMessages(
                                                  contacts[index].id);
                                              databaseHelper.deleteContact(
                                                  contacts[index].id);
                                              setState(() {
                                                init();
                                              });
                                            },
                                            child: const Column(children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 30,
                                              ),
                                              Text(
                                                'supprimer',
                                                style: TextStyle(fontSize: 12),
                                              )
                                            ]))
                                      ])
                                    : Container()
                              ]),
                          leading: KAvatar(
                            imageAssetPath: contact.img,
                            scale: contact.scale,
                            offset: Offset(
                                contact.offsetX / 1.9, contact.offsetY / 2.1),
                            radius: 28,
                            borderSize: 2,
                            connected: contact.connected,
                          ),
                          trailing:
                              // Row(children: [
                              unreadMsgs.containsKey(contact.id)
                                  ? Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: Text(
                                        '${unreadMsgs[contact.id]}',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                    height: 1.0,
                  ),
                ],
              );
            },
          ),
          const SizedBox(
            height: 50,
          ),
          contacts.isEmpty
              ? const Center(
                  child: Text(
                      "Vous n'avez encore contacté personne, envoyez un message à une personne autour de vous pour commencer à discuter."),
                )
              : Container(),
        ]));
  }
}
