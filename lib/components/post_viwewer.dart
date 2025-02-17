import 'package:flutter/material.dart';
import 'package:kaouka/components/audio_player.dart';
import 'package:kaouka/components/photo_viewer.dart';
import 'package:kaouka/components/video_player.dart';
import 'package:kaouka/database.dart';
import 'package:kaouka/utils.dart';

// ignore: must_be_immutable
class PostViewer extends StatefulWidget {
  final String media;
  final bool isFeed;
  final bool isPost;
  String ts;
  String personId;
  PostViewer(
      {super.key,
      required this.media,
      required this.isFeed,
      required this.isPost,
      this.ts = "",
      this.personId = ""});

  @override
  State<PostViewer> createState() => _PostViewerState();
}

class _PostViewerState extends State<PostViewer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (getFileType(widget.media).fileType) {
      case FileType.image:
        return PhotoViewer(
          imagePath: widget.media,
          isPost: widget.isPost,
          isPreview: false,
          isFeed: widget.isFeed,
          ts: widget.ts,
          personId: widget.personId,
        );
      case FileType.video:
        return VideoPlayer(
          videoPath: widget.media,
          isPost: widget.isPost,
          isPreview: false,
          isFeed: widget.isFeed,
          ts: widget.ts,
          personId: widget.personId,
        );

      case (FileType.audio):
        return AudioPlayer(
          audioPath: widget.media,
          isPost: widget.isPost,
          isOwn: false,
          ts: widget.ts,
          personId: widget.personId,
        );
      default:
        // should be an error image
        final DatabaseHelper databaseHelper = DatabaseHelper.instance;
        databaseHelper.deleteMessageMedia(widget.personId, widget.ts);
        return Container(
          height: 50,
          // color: Colors.black,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey),
            color: Colors.black,
          ),
          child: const Center(
            child: Text(
              "Media non disponible",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
    }
  }
}
