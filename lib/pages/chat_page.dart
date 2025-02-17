import 'dart:io';
import 'package:kaouka/components/input_bar.dart';
import 'package:kaouka/http_manager.dart';
import 'package:kaouka/notifiers/message_notifier.dart';
import 'package:kaouka/utils.dart';
import '/notifiers/mode_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../components/chat_bubble.dart';
import '../components/kavatar.dart';
import '../database.dart';
import '../message.dart';
import '../theme.dart';
import '../shared_data.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class ChatPage extends StatefulWidget {
  final String id;
  final void Function() navBack;

  const ChatPage({super.key, required this.id, required this.navBack});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<CustomMessage> messages = [];
  String text = "";
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String pseudo = "undefined";
  late String img = "https://elaborium.site/proxy/stream/default/profile.jpg";
  late double scale = 1.0;
  late double offsetX = 0.0;
  late double offsetY = 0.0;
  bool connected = false;

  Future<void> getMessages() async {
    await databaseHelper.readMessages(widget.id);
    final tmp = await databaseHelper.getMessages(widget.id);
    FlutterAppBadger.removeBadge();
    // for (CustomMessage message in tmp) {
    //   print(message.message);
    //   print(message.timestamp);
    // }
    setState(() {
      messages = tmp;
    });
  }

  void _handleMessageChange() async {
    await getMessages();
    scrollToBottom();
    widget.navBack();
    MessageNotifier.instance.clear();
  }

  void scrollToBottom() {
    if (messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }

  void getUserInfos() async {
    final infos = await getInfos(widget.id);
    setState(() {
      pseudo = infos.name;
      img = infos.img;
      scale = infos.scale;
      offsetX = infos.offsetX;
      offsetY = infos.offsetY;
      connected = infos.connected;
    });
  }

  Future<bool> _submit(File file) async {
    SharedData shared = SharedData();
    String? id = shared.getId;
    if (_textEditingController.text.isEmpty && file.path.isEmpty) return false;
    dynamic ret =
        await sendMsg(id, widget.id, _textEditingController.text, file);
    if (ret.elementAt(0) == true) {
      DateTime currentTimeUtc = DateTime.now().toUtc();
      String timestampIsoString = currentTimeUtc.toIso8601String();
      setState(() {
        messages.add(CustomMessage(
            isSentByUser: true,
            message: _textEditingController.text,
            timestamp: timestampIsoString,
            personId: widget.id,
            filepath: ret.elementAt(1),
            read: true));
        _textEditingController.clear();
        scrollToBottom();
      });
      return true;
    } else if (ret.elementAt(1) == "blocked") {
      showPopUp(context, "info", "l'utilisateur vous a bloqué", () => ());
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    getUserInfos();
    MessageNotifier.instance.addListener(_handleMessageChange);
    getMessages();
    widget.navBack();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.navBack();
      MessageNotifier.instance.clear();
    });
    scrollToBottom();
  }

  @override
  void dispose() {
    MessageNotifier.instance.removeListener(_handleMessageChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PersistentModeProvider darkMode =
        Provider.of<PersistentModeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          KAvatar(
            imageAssetPath: img,
            scale: scale == 0.0 ? 1.0 : scale,
            offset: Offset(offsetX / 2.7, offsetY / 3),
            radius: 20,
            borderSize: 2,
            connected: connected,
          ),
          const SizedBox(width: 10.0),
          Text(pseudo),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      var message = messages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0.0),
                        child: ListTile(
                          tileColor: darkMode.isModeChanged
                              ? const Color.fromARGB(255, 4, 7, 47)
                              : backgroundDark,
                          title: ChatBubble(
                            message: message,
                          ),
                        ),
                      );
                    }),
              ),
            ),
            InputBar(
              onSubmitted: _submit,
              hintText: 'Donnez vous rendez-vous',
              onChanged: (value) {},
              controller: _textEditingController,
              maxLines: 1,
              maxLength: 200,
              isMessage: true,
            ),
          ],
        ),
      ),
    );
  }
}
