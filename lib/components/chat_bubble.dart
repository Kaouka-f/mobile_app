import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:kaouka/components/post_viwewer.dart';
import 'package:kaouka/core/database.dart';

import 'package:kaouka/core/shared_data.dart';
import 'package:kaouka/http/routes/post/delete_msg.dart';
import 'package:kaouka/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/message.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

class ChatBubble extends StatelessWidget {
  final CustomMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onDoubleTap: () => {print('double')},
      onLongPress: () => {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                      onPressed: () {
                        copyToClipboard(context, message.message);
                        Navigator.pop(context);
                      },
                      child: const Text('Copier le message',
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final DatabaseHelper databaseHelper =
                            DatabaseHelper.instance;
                        databaseHelper.deleteMessage(
                            message.personId, message.timestamp);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Text(
                        'supprimer le message',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  message.filepath.isNotEmpty
                      ? SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              SharedData sharedData = SharedData();
                              if (message.filepath.isNotEmpty) {
                                String ret = await deleteMsg(
                                    sharedData.id, message.filepath);
                                if (ret == "true") {
                                  final DatabaseHelper databaseHelper =
                                      DatabaseHelper.instance;
                                  databaseHelper.deleteMessageMedia(
                                      message.personId, message.timestamp);
                                }
                              }
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                            ),
                            child: const Text(
                              'supprimer le media',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        )
                      : Container(),
                ]));
          },
        )
      },
      child: Align(
        alignment:
            message.isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.82,
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isSentByUser ? messageSent : messageReceive,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              message.filepath.isNotEmpty
                  ? PostViewer(
                      media: message.filepath,
                      isFeed: false,
                      isPost: true,
                      ts: message.timestamp,
                      personId: message.personId,
                    )
                  : Container(),
              SelectableLinkify(
                onOpen: (link) async {
                  if (await canLaunch(link.url)) {
                    await launch(link.url);
                  } else {
                    throw 'Could not launch $link';
                  }
                },
                enableInteractiveSelection: false,
                text: message.message,
                style: const TextStyle(color: textColor2),
              ),
              // Text(
              //   message.message,
              //   style: const TextStyle(color: textColor2),
              // ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    timestampToDate(message.timestamp),
                    style: const TextStyle(color: textColor2, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
