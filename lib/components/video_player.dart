import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kaouka/database.dart';
import 'package:video_player/video_player.dart' as vp;

// ignore: must_be_immutable
class VideoPlayer extends StatefulWidget {
  final String videoPath;
  final bool isPreview;
  final bool isPost;
  final bool isFeed;
  final Function? onCancel;
  String ts;
  String personId;
  VideoPlayer(
      {super.key,
      required this.videoPath,
      required this.isPreview,
      required this.isPost,
      required this.isFeed,
      this.onCancel,
      this.ts = "",
      this.personId = ""});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late vp.VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      if (widget.isPost) {
        _controller = vp.VideoPlayerController.networkUrl(
          Uri.parse(widget.videoPath),
        );
      } else {
        _controller = vp.VideoPlayerController.file(
          File(widget.videoPath),
        );
      }
      _initializeVideoPlayerFuture = _controller.initialize();
      _controller.setLooping(true);
    } catch (e) {
      print("Error initializing video: $e");
      setState(() {
        final DatabaseHelper databaseHelper = DatabaseHelper.instance;
        databaseHelper.deleteMessageMedia(widget.personId, widget.ts);
        _hasError = true; // Set error flag to display error UI
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: widget.isPreview ? 100 : null,
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    final DatabaseHelper databaseHelper =
                        DatabaseHelper.instance;
                    databaseHelper.deleteMessageMedia(
                        widget.personId, widget.ts);
                    // Display error message if initialization failed
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
                          "vidéo supprimé",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    // Display video if loaded successfully
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: vp.VideoPlayer(_controller),
                    );
                  } else {
                    // Show loading indicator while the video is loading
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            if (!_hasError)
              FloatingActionButton(
                onPressed: () {
                  if (_controller.value.isPlaying) {
                    setState(() {
                      _controller.pause();
                    });
                  } else {
                    setState(() {
                      _controller.play();
                    });
                  }
                },
                backgroundColor: Colors.transparent,
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            !widget.isPreview && !widget.isPost && !_hasError
                ? Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                      onPressed: () => {
                        Navigator.pop(context),
                      },
                      icon: const Icon(Icons.check),
                    ),
                  )
                : Container(),
            !widget.isPost
                ? Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () => {widget.onCancel?.call()},
                      icon: const Icon(Icons.cancel_sharp),
                    ))
                : Container(),
          ],
        ),
      ],
    );
  }
}
