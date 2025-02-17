import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaouka/components/audio_player.dart';
import 'package:kaouka/components/camera.dart';
import 'package:kaouka/components/photo_viewer.dart';
import 'package:kaouka/components/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:kaouka/utils.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class InputBar extends StatefulWidget {
  final String hintText;
  final int maxLines;
  final int maxLength;
  final Function(String) onChanged;
  final Function(File) onSubmitted;
  final TextEditingController? controller;
  bool isMessage;

  InputBar(
      {super.key,
      required this.hintText,
      required this.maxLines,
      required this.maxLength,
      required this.onChanged,
      this.controller,
      required this.onSubmitted,
      this.isMessage = false});

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  late TextEditingController _controller;
  bool load = false;
  bool submitted = false;
  String filePath = '';
  late Timer _timer;
  void onFileSelected(String path) {
    setState(() {
      filePath = path;
    });
  }

  cancel() {
    setState(() {
      filePath = '';
    });
  }

  void _showGallery() async {
    final picker = ImagePicker();
    final pickedXFile = await picker.pickImage(source: ImageSource.gallery);
    onFileSelected(pickedXFile!.path);
  }

  void _closeKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  bool isRecording = false;
  AudioRecorder recorder = AudioRecorder();
  RecordConfig config = const RecordConfig();
  startRecorder() async {
    try {
      if (await recorder.hasPermission()) {
        _timer = Timer.periodic(const Duration(seconds: 1), _checkAudioTime);
        var uuid = const Uuid();
        String uniqueId = uuid.v4();
        final directory = await getApplicationDocumentsDirectory();
        final audioDirectory = '${directory.path}/$uniqueId.m4a';
        if (await File(audioDirectory).exists()) {
          await File(audioDirectory).delete();
        }
        recorder.start(
          config,
          path: audioDirectory,
        );
        setState(() {
          isRecording = true;
        });
      } else {
        // ignore: use_build_context_synchronously
        showPopUp(context, 'Permission Microphone',
            'Autoriser le microphone pour enregistrer un message vocal.',
            () async {
          await openAppSettings();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('start record error: $e');
      }
    }
  }

  stopRecorder() async {
    try {
      final audio_path = await recorder.stop();
      if (audio_path != null) {
        isRecording = false;
        onFileSelected(audio_path);
      }
    } catch (e) {
      if (kDebugMode) {
        print('record error: $e');
      }
    }
  }

  Future<void> _checkAudioTime(Timer timer) async {
    if (timer.tick == 180) {
      _timer.cancel();
      stopRecorder();
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            getFileType(filePath).fileType == FileType.image
                ? GestureDetector(
                    onTap: () async => {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PhotoViewer(
                            imagePath: filePath,
                            isPost: false,
                            isPreview: false,
                            isFeed: false,
                          ),
                        ),
                      )
                    },
                    child: PhotoViewer(
                      imagePath: filePath,
                      isPost: false,
                      isPreview: true,
                      isFeed: false,
                      onCancel: cancel,
                    ),
                  )
                : Container(),
            getFileType(filePath).fileType == FileType.video
                ? GestureDetector(
                    onTap: () async => {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => VideoPlayer(
                                  videoPath: filePath,
                                  isPost: false,
                                  isPreview: false,
                                  isFeed: false,
                                )),
                      ),
                    },
                    child: VideoPlayer(
                      videoPath: filePath,
                      isPost: false,
                      isPreview: true,
                      isFeed: false,
                      onCancel: cancel,
                    ),
                  )
                : Container(),
            getFileType(filePath).fileType == FileType.audio
                ? AudioPlayer(
                    audioPath: filePath,
                    isPost: false,
                    isOwn: true,
                    onCancel: cancel,
                  )
                : Container(),
            submitted ? const Text("envoyé") : const SizedBox(),
            load
                ? const LinearProgressIndicator(
                    color: Colors.white,
                  )
                : const SizedBox(),
            TextField(
              scrollPhysics: const AlwaysScrollableScrollPhysics(),
              controller: _controller,
              onChanged: widget.onChanged,
              minLines: widget.maxLines != 0 ? widget.maxLines : null,
              maxLines: 5,
              maxLength: widget.maxLength,
              textInputAction: TextInputAction.done,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: Colors.white,
              cursorHeight: 20,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    File file;
                    file = File(filePath);
                    setState(() {
                      load = true;
                    });
                    bool ret = await widget.onSubmitted(file);
                    if (ret) {
                      setState(() {
                        load = false;
                        submitted = true;
                      });
                      // ignore: use_build_context_synchronously
                      _closeKeyboard(context);
                      widget.onChanged(_controller.text);
                      setState(() {
                        filePath = '';
                      });
                      await Future.delayed(const Duration(seconds: 2));
                      setState(() {
                        submitted = false;
                      });
                    }
                  },
                ),
                prefixIcon: !widget.isMessage
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo_camera_outlined),
                            onPressed: () async {
                              _closeKeyboard(context);
                              final cameras = await availableCameras();
                              // ignore: use_build_context_synchronously
                              showDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog.fullscreen(
                                      child: Camera(
                                        cameras: cameras,
                                        onFileSelected: onFileSelected,
                                      ),
                                    );
                                  });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.mic_none_rounded),
                            color: isRecording ? Colors.red : Colors.white,
                            onPressed: () async {
                              if (isRecording) {
                                await stopRecorder();
                              } else {
                                await startRecorder();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            color: Colors.white,
                            onPressed: () async {
                              _showGallery();
                            },
                          ),
                        ],
                      )
                    : const SizedBox(),
                // isDense: true,
                filled: true,
                // counterText: '10',
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              onTapOutside: (pointer) => _closeKeyboard(context),
            ),
          ],
        );
      },
    );
  }
}
