import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_echo/flutter_echo.dart';
import 'package:just_audio/just_audio.dart' as just;
import 'package:kaouka/database.dart';
import 'package:rxdart/rxdart.dart';

// ignore: must_be_immutable
class AudioPlayer extends StatefulWidget {
  final String audioPath;
  final bool isPost;
  final bool isOwn;
  final Function? onCancel;
  String ts;
  String personId;
  AudioPlayer(
      {super.key,
      required this.audioPath,
      required this.isPost,
      required this.isOwn,
      this.onCancel,
      this.ts = "",
      this.personId = ""});

  @override
  AudioPlayerState createState() => AudioPlayerState();
}

class AudioPlayerState extends State<AudioPlayer> with WidgetsBindingObserver {
  final _player = just.AudioPlayer();
  bool audio_broken = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      audio_broken = true;
      final DatabaseHelper databaseHelper = DatabaseHelper.instance;
      databaseHelper.deleteMessageMedia(widget.personId, widget.ts);
      if (kDebugMode) print('A stream error occurred: $e');
    });
    try {
      if (widget.isPost) {
        await _player
            .setAudioSource(just.AudioSource.uri(Uri.parse(widget.audioPath)));
      } else {
        await _player.setAudioSource(just.AudioSource.file(widget.audioPath));
      }
    } catch (e) {
      setState(() {
        audio_broken = true;
        final DatabaseHelper databaseHelper = DatabaseHelper.instance;
        databaseHelper.deleteMessageMedia(widget.personId, widget.ts);
      });

      if (kDebugMode) print("Error loading audio source: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _player.stop();
    }
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return !audio_broken
        ? SafeArea(
            child: FittedBox(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.orange],
                    stops: [0.1, 0.9],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ControlButtons(_player, widget.onCancel, widget.isOwn),
                    StreamBuilder<PositionData>(
                      stream: _positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return SeekBar(
                          duration: positionData?.duration ?? Duration.zero,
                          position: positionData?.position ?? Duration.zero,
                          bufferedPosition:
                              positionData?.bufferedPosition ?? Duration.zero,
                          onChangeEnd: _player.seek,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        : Container(
            height: 50,
            // color: Colors.black,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.grey),
              color: Colors.black,
            ),
            child: const Center(
              child: Text(
                "audio supprimé",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
  }
}

class ControlButtons extends StatelessWidget {
  final just.AudioPlayer player;
  final Function? onCancel;
  final bool isOwn;

  const ControlButtons(this.player, this.onCancel, this.isOwn, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: [
        !isOwn
            ? Container()
            : SizedBox(
                width: 20,
                child: IconButton(
                    padding: EdgeInsets.zero, // Ensure no padding
                    // margin: EdgeInsets.zero,
                    onPressed: () => {onCancel?.call()},
                    iconSize: 30,
                    color: Colors.black,
                    icon: const Icon(Icons.cancel)),
              ),
        SizedBox(
          width: 30,
          child: StreamBuilder<just.PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == just.ProcessingState.loading ||
                  processingState == just.ProcessingState.buffering) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: 30.0,
                  height: 30.0,
                  color: Colors.black,
                  child: const CircularProgressIndicator(),
                );
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(Icons.play_arrow),
                  iconSize: 30.0,
                  color: Colors.black,
                  onPressed: player.play,
                );
              } else if (processingState != just.ProcessingState.completed) {
                return IconButton(
                  icon: const Icon(Icons.pause),
                  iconSize: 30.0,
                  color: Colors.black,
                  onPressed: player.pause,
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.replay),
                  iconSize: 30.0,
                  color: Colors.black,
                  onPressed: () => player.seek(Duration.zero),
                );
              }
            },
          ),
        ),
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                value: player.speed,
                stream: player.speedStream,
                onChanged: player.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}
