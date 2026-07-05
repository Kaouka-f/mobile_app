import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:kaouka/components/kavatar.dart';
import 'package:kaouka/components/post_viwewer.dart';
import 'package:kaouka/components/tile_bottom_bar.dart';
import 'package:kaouka/models/person.dart';
import 'package:kaouka/models/request.dart';
import 'package:kaouka/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestCard extends StatefulWidget {
  final Person person;
  final Request request;
  final bool isOwn;

  const RequestCard(
      {super.key,
      required this.person,
      required this.request,
      required this.isOwn});

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  late bool isToggled;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 16.0),
      Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 20,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(99, 255, 255, 255),
              blurRadius: 20.0,
              offset: Offset(0, 0),
            ),
          ],
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     Color.fromARGB(110, 0, 0, 0),
          //     Color.fromARGB(95, 0, 0, 0),
          //   ],
          // ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                KAvatar(
                  imageAssetPath: widget.person.img,
                  scale: widget.person.scale,
                  offset: Offset(
                      widget.person.offsetX / 1.9, widget.person.offsetY / 2.1),
                  radius: 28,
                  borderSize: 2,
                  connected: widget.person.connected,
                ),
                const SizedBox(width: 8.0),
                Text(
                  widget.person.name,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  timestampUnixToDate(widget.request.reqTime),
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            widget.request.media.isNotEmpty
                ? PostViewer(
                    media: widget.request.media,
                    isFeed: true,
                    isPost: true,
                  )
                : Container(),
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 20,
                ),
                child: SelectableLinkify(
                  onOpen: (link) async {
                    if (await canLaunch(link.url)) {
                      await launch(link.url);
                    } else {
                      throw 'Could not launch $link';
                    }
                  },
                  text: widget.request.request,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
      TileBottomBar(
        request: widget.request,
        person: widget.person,
        commentNb: widget.request.commentNb,
        signalNb: widget.request.signalNb,
        isOwn: widget.isOwn,
      ),
    ]);
  }
}
