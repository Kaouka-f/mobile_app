import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kaouka/components/input_bar.dart';
import 'package:kaouka/database.dart';
import 'package:kaouka/http_manager.dart';
import 'package:kaouka/pages/chat_page.dart';
import 'package:kaouka/shared_data.dart';

class PostBottomBar extends StatefulWidget {
  final String reqId;
  final String personId;
  final bool isOwn;

  const PostBottomBar({
    super.key,
    required this.reqId,
    required this.personId,
    required this.isOwn,
  });

  @override
  State<PostBottomBar> createState() => _PostBottomBarState();
}

class _PostBottomBarState extends State<PostBottomBar> {
  final TextEditingController _textEditingController = TextEditingController();
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  SharedData sharedData = SharedData();
  late String id;

  Future<void> _submit(File file) async {
    if (_textEditingController.text.isNotEmpty || file.path.isNotEmpty) {
      final res = await postComments(
          id, widget.reqId, _textEditingController.text, file);
      if (res != null) {
        if (kDebugMode) {
          print(res);
        }
        if (res['status'] == 200 && res['res'] == 'true') {
          _textEditingController.clear();
          databaseHelper.insertReqInteressedDb(widget.reqId);
        } else {
          // ignore: use_build_context_synchronously
          showAboutDialog(context: context, children: [
            const Text(
                'Une erreur est survenue le commentaire n\'as pas pu etre transmis'),
          ]);
        }
      }
    }
    // TODO: go to home page
  }

  @override
  void initState() {
    id = sharedData.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            await likeReq(id, widget.reqId);
            await getLikes(widget.reqId);
          },
          child: const Icon(
            Icons.volunteer_activism_sharp,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return SingleChildScrollView(
                    // Set reverse to true to make the list grow upwards
                    reverse: true,
                    // Padding to keep text from being hidden under the app bar
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: InputBar(
                      onSubmitted: _submit,
                      hintText: 'Send a request',
                      onChanged: (value) {},
                      controller: _textEditingController,
                      maxLines: 1,
                      maxLength: 200,
                    ));
              },
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 20),
        widget.isOwn
            ? ElevatedButton(
                onPressed: () async {
                  await deleteReq(id, widget.reqId);
                  // widget.changed();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.delete,
                  color: Colors.black,
                ),
              )
            : ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        id: widget.personId,
                        navBack: () {},
                      ),
                    ),
                  );
                },
                child: const Icon(
                  Icons.send_to_mobile,
                  color: Colors.black,
                ),
              ),
      ],
    );
  }
}
