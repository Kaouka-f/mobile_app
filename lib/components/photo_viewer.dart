import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kaouka/database.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatelessWidget {
  final String imagePath;
  final bool isPreview;
  final bool isPost;
  final bool isFeed;
  final Function? onCancel;
  final String ts;
  final String personId;

  const PhotoViewer({
    super.key,
    required this.imagePath,
    required this.isPreview,
    required this.isPost,
    required this.isFeed,
    this.onCancel,
    this.ts = "",
    this.personId = "",
  });

  Future<bool> deleteFile(String filePath) async {
    final file = File(filePath);
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  bool isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper databaseHelper = DatabaseHelper.instance;
    ImageProvider imageProvider;

    if (isPost || isNetworkImage(imagePath)) {
      // Network image case
      imageProvider = NetworkImage(imagePath);
      return Column(
        children: [
          FutureBuilder(
            future: precacheImage(NetworkImage(imagePath), context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // Handle network image load error
                databaseHelper.deleteMessageMedia(personId, ts);
                return _buildErrorContainer();
              } else {
                return
                    // width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height,
                    PhotoView(
                  tightMode: true,
                  customSize:
                      isPreview ? const Size(70, 70) : const Size(300, 300),
                  imageProvider: imageProvider,
                  scaleStateCycle: (PhotoViewScaleState actual) {
                    return PhotoViewScaleState.originalSize;
                  },
                );
              }
            },
          ),
          if (isPreview) _buildCancelButton(context),
          // if (isPreview) _buildDeleteButton(context),
        ],
      );
    } else {
      // Local file case
      imageProvider = FileImage(File(imagePath));

      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            child: FutureBuilder(
              future: File(imagePath).exists(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (!snapshot.hasData || snapshot.data == false) {
                  // Handle local file not found
                  databaseHelper.deleteMessageMedia(personId, ts);
                  return _buildErrorContainer();
                } else {
                  return PhotoView(
                    // onTapDown: (BuildContext c, TapDownDetails d,
                    //         PhotoViewControllerValue p) =>
                    //     {print("tap photo")},
                    tightMode: true,
                    customSize: isPreview ? const Size(150, 150) : null,
                    imageProvider: imageProvider,
                  );
                }
              },
            ),
          ),
          if (isPreview)
            Positioned(
                // left: 0,
                right: 0,
                top: 0,
                child: _buildDeleteButton(context)),
        ],
      );
    }
  }

  Widget _buildErrorContainer() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey),
        color: Colors.black,
      ),
      child: const Center(
        child: Text(
          "Image supprimée",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.check_circle_sharp),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      onPressed: () async {
        onCancel?.call();
      },
      icon: const Icon(Icons.cancel_sharp),
    );
  }
}
