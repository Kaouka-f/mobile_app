import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaouka/components/input_bar.dart';
import 'package:kaouka/core/database.dart';
import 'package:kaouka/http/routes/get/get_likes.dart';
import 'package:kaouka/http/routes/post/like_req.dart';
import 'package:kaouka/http/routes/post/post_comments.dart';
import 'package:kaouka/http/routes/post/signal_req.dart';

import 'package:kaouka/pages/chat_page.dart';
import 'package:kaouka/models/person.dart';
import 'package:kaouka/models/request.dart';
import 'package:kaouka/core/shared_data.dart';
import 'package:kaouka/utils.dart';

class TileBottomBar extends StatefulWidget {
  final Request request;
  final Person person;
  final int commentNb;
  final int signalNb;
  final bool isOwn;
  final Function? refresh;
  final Function? onDeletion;

  const TileBottomBar({
    super.key,
    required this.request,
    required this.person,
    this.commentNb = 0,
    this.isOwn = false,
    required this.signalNb,
    this.refresh,
    this.onDeletion,
  });

  @override
  State<TileBottomBar> createState() => _TileBottomBarState();
}

class _TileBottomBarState extends State<TileBottomBar> {
  final TextEditingController _textEditingController = TextEditingController();
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  SharedData sharedData = SharedData();
  late String id;
  List<String> likes = [];

  Future<void> _submit(File file) async {
    if (_textEditingController.text.isNotEmpty) {
      final res = await postComments(
          id, widget.request.reqId, _textEditingController.text, file);
      bool ret = false;
      if (res.toString().contains('res')) {
        final resDecode = json.decode(res);
        if (resDecode['res'] == 'true') {
          _textEditingController.clear();
          databaseHelper.insertReqInteressedDb(widget.request.reqId);
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        } else {
          ret = true;
        }
      } else {
        ret = true;
      }
      if (ret) {
        // ignore: use_build_context_synchronously
        showPopUp(
          // ignore: use_build_context_synchronously
          context,
          'Erreur',
          'Une erreur est survenue le commentaire n\'as pas pu etre transmis',
          () {},
        );
      }
    }
  }

  init() async {
    final likes = stringListFromJson(await getLikes(widget.request.reqId));
    setState(() {
      this.likes = likes;
    });
  }

  @override
  void initState() {
    id = sharedData.id;
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          style: ButtonStyle(
            iconColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.blue; // Change icon color when pressed
                }
                if (likes.contains(id)) {
                  return Colors.red; // Change icon color when pressed
                }
                return Colors.white; // Default icon color
              },
            ),
          ),
          iconSize: 15,
          onPressed: () async {
            await likeReq(id, widget.request.reqId);
            final likes =
                stringListFromJson(await getLikes(widget.request.reqId));
            setState(() {
              this.likes = likes;
            });
            if (likes.contains(id)) {
              databaseHelper.insertReqInteressedDb(widget.request.reqId);
            } else {
              databaseHelper.deleteReqInteressedDb(widget.request.reqId);
            }
          },
          icon: Column(
            children: [
              const Icon(Icons.favorite),
              Text(
                likes.length.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        IconButton(
          style: ButtonStyle(
            iconColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.blue; // Change icon color when pressed
                }
                return Colors.white; // Default icon color
              },
            ),
          ),
          iconSize: 15,
          onPressed: () async {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
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
          icon: Column(
            children: [
              const Icon(Icons.comment),
              Text(
                widget.commentNb.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        IconButton(
          style: ButtonStyle(
            iconColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.blue; // Change icon color when pressed
                }
                return Colors.white; // Default icon color
              },
            ),
          ),
          iconSize: 15,
          onPressed: () async {
            widget.isOwn
                ? (
                    await widget.onDeletion!(id, widget.request.reqId),
                    widget.refresh!()
                  )
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        id: widget.person.id,
                        navBack: () {},
                      ),
                    ),
                  );
          },
          icon: Column(
            children: [
              widget.isOwn ? const Icon(Icons.delete) : const Icon(Icons.send),
              Text(
                widget.isOwn ? 'supprimer' : "message",
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        IconButton(
          style: ButtonStyle(
            iconColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.white;
                }
                return Colors.red;
              },
            ),
          ),
          iconSize: 15,
          onPressed: () async {
            // signal request
            signalReq(id, widget.request.reqId);
          },
          icon: Column(
            children: [
              const Icon(Icons.warning_outlined),
              Text(
                widget.signalNb.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        IconButton(
          style: ButtonStyle(
            iconColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.white;
                }
                return Colors.blue;
              },
            ),
          ),
          iconSize: 15,
          onPressed: () async {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      copyToClipboard(context,
                          "https://elaborium.site/proxy/preview?reqId=${widget.request.reqId}");
                      // "http://192.168.1.49:8000/proxy/preview?reqId=${widget.request.reqId}");
                      Navigator.pop(context);
                    },
                    child: const Text('Copier le lien'),
                  ),
                );
              },
            );
          },
          icon: const Column(
            children: [
              Icon(Icons.share),
              Text(
                "partager",
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
