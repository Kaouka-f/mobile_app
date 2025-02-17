// A screen that allows users to take a picture using a given camera.
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kaouka/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function onFileSelected;

  const Camera({
    super.key,
    required this.cameras,
    required this.onFileSelected,
  });

  @override
  CameraState createState() => CameraState();
}

class CameraState extends State<Camera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int _selectedCameraIndex = 0;
  bool isLoading = false;
  bool isRecording = false;
  bool flash = false;
  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;
  final double _maxZoomLevel = 15.0;
  late Timer _timer;

  initCamera() async {
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    _controller.addListener(() {
      if (_controller.value.hasError) {
        if (kDebugMode) {
          print('cam error ${_controller.value.errorDescription}');
        }
      }
    });

    // _initializeControllerFuture = _controller.initialize();
    _initializeControllerFuture = _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller.setFlashMode(FlashMode.off);
      _controller.setZoomLevel(1.0);
      _controller.setFocusMode(FocusMode.auto);
    }).onError((error, stackTrace) {
      // ignore: use_build_context_synchronously
      showPopUp(context, 'Permission Caméra ou Microphone',
          'Autoriser la caméra et le microphone dans les reglages de l\'application pour prendre une photo.',
          () async {
        await openAppSettings();
      });
    });

    isLoading = true;
  }

  setFlash() {
    flash
        ? _controller.setFlashMode(FlashMode.off)
        : _controller.setFlashMode(FlashMode.torch);
    setState(() {
      flash = !flash;
    });
  }

  cancel() {
    Navigator.pop(context);
  }

  returnCamera() {
    if (widget.cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
    _controller = CameraController(
      widget.cameras[_selectedCameraIndex],
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  // Focus not working as expected
  Future<void> _setFocus(
      TapDownDetails details, BoxConstraints constraints) async {
    if (!_controller.value.isInitialized) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    try {
      await _controller.setFocusPoint(offset);
    } catch (e) {
      if (kDebugMode) print('Error setting focus point: $e');
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoomLevel = _currentZoomLevel;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_controller.value.isInitialized) {
      setState(() {
        _currentZoomLevel =
            (_baseZoomLevel * details.scale).clamp(1.0, _maxZoomLevel);
        _controller.setZoomLevel(_currentZoomLevel);
      });
    }
  }

  startRecording() async {
    try {
      await _initializeControllerFuture;
      await _controller.startVideoRecording();
      _timer = Timer.periodic(const Duration(seconds: 1), _checkVideoTime);
      setState(() {
        isRecording = true;
      });
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  stopRecording() async {
    try {
      _timer.cancel();
      final video = await _controller.stopVideoRecording();
      var uuid = const Uuid();
      String uniqueId = uuid.v4();
      String extension = path.extension(video.name);
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/$uniqueId.$extension';
      await video.saveTo(newPath);
      widget.onFileSelected(newPath);
      setState(() {
        isRecording = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> _checkVideoTime(Timer timer) async {
    if (timer.tick == 20) {
      _timer.cancel();
      stopRecording();
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fill this out in the next steps.
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) => _setFocus(details, constraints),
                onScaleStart: _handleScaleStart,
                onScaleUpdate: _handleScaleUpdate,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_controller),
                    Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                try {
                                  await _initializeControllerFuture;
                                  final image = await _controller.takePicture();
                                  var uuid = const Uuid();
                                  String uniqueId = uuid.v4();
                                  String extension = path.extension(image.name);
                                  final directory =
                                      await getApplicationDocumentsDirectory();
                                  final newPath =
                                      '${directory.path}/$uniqueId$extension';
                                  await image.saveTo(newPath);
                                  widget.onFileSelected(newPath);
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context);
                                } catch (e) {
                                  if (kDebugMode) print(e);
                                }
                              },
                              onLongPress: startRecording,
                              onLongPressEnd: (details) async {
                                stopRecording();
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(isRecording
                                          ? 0.5
                                          : 0), // Shadow color with 50% opacity
                                      spreadRadius: 1, // Spread radius
                                      blurRadius: 50, // Blur radius
                                      offset: const Offset(
                                          0, 0), // Offset from the button
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color:
                                      isRecording ? Colors.red : Colors.white,
                                  size: isRecording ? 80 : 70,
                                ),
                              ),
                            ),
                            IconButton(
                                icon: const Icon(Icons.camera),
                                iconSize: 80,
                                color: isRecording ? Colors.red : Colors.white,
                                onPressed: () {
                                  print(isRecording);
                                  if (!isRecording) {
                                    startRecording();
                                  } else {
                                    stopRecording();
                                  }
                                }),
                          ]),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.replay_outlined),
                              iconSize: 50,
                              onPressed: returnCamera),
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined),
                            onPressed: cancel,
                            iconSize: 50,
                          ),
                          IconButton(
                            icon: Icon(flash
                                ? Icons.flashlight_on
                                : Icons.flashlight_off),
                            onPressed: setFlash,
                            iconSize: 50,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}
