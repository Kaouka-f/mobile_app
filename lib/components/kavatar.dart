import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:kaouka/components/photo_viewer.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class KAvatar extends StatefulWidget {
  String imageAssetPath;
  double scale;
  Offset offset;
  double radius;
  bool connected;
  final Function? imageChanged;
  final double borderSize;
  final bool isSetter;

  KAvatar({
    super.key,
    this.imageAssetPath =
        "https://elaborium.site/proxy/stream/default/profile.jpg",
    this.scale = 1.0,
    this.offset = Offset.zero,
    this.radius = 0.0,
    this.imageChanged,
    this.connected = false,
    this.isSetter = false,
    this.borderSize = 0,
  });
  @override
  State<KAvatar> createState() => _KAvatarState();
}

class _KAvatarState extends State<KAvatar> {
  final String defaultImg =
      "https://elaborium.site/proxy/stream/default/profile.jpg";

  void _updateImageOffset(DragUpdateDetails details) {
    setState(() {
      widget.offset += details.delta;
    });
    widget.imageChanged!(widget.imageAssetPath, widget.offset);
  }

  bool isUrl(String path) {
    bool res = path.startsWith("https");
    res = path.startsWith("http");
    return res;
  }

  void _showGallery() async {
    final picker = ImagePicker();
    final pickedXFile = await picker.pickImage(source: ImageSource.gallery);
    final pickedFile = File(pickedXFile!.path);
    setState(() {
      widget.imageAssetPath = pickedFile.path;
    });
    widget.imageChanged!(widget.imageAssetPath, widget.offset);
  }

  Color getBorderColor(bool isConnected, bool isSetter) {
    if (!isSetter) {
      if (isConnected) {
        return const Color.fromARGB(255, 64, 255, 0);
      } else {
        return Colors.grey;
      }
    } else {
      return Colors.transparent;
    }
  }

  @override
  void initState() {
    if (widget.imageAssetPath.isEmpty || widget.imageAssetPath == "") {
      widget.imageAssetPath =
          "https://elaborium.site/proxy/stream/default/profile.jpg";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isSetter) {
          _showGallery();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: const Text('Photo'),
                ),
                body: PhotoViewer(
                  imagePath: widget.imageAssetPath,
                  isPreview: false,
                  isPost: true,
                  isFeed: false,
                ),
              ),
            ),
          );
        }
      },
      onPanUpdate: widget.isSetter ? _updateImageOffset : null,
      child: Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          color: const Color(0xff7c94b6),
          borderRadius: const BorderRadius.all(Radius.circular(200 / 2)),
          border: Border.all(
            color: widget.connected
                ? const Color.fromARGB(255, 64, 255, 0)
                : Colors.grey,
            width: widget.borderSize,
          ),
        ),
        child: ClipOval(
          child: SizedBox(
            width: widget.radius * 2,
            height: widget.radius * 2,
            child: Transform.translate(
              offset: widget.offset,
              child: Transform.scale(
                  scale: widget.scale,
                  child: isUrl(widget.imageAssetPath)
                      ? Image.network(
                          widget.imageAssetPath,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(defaultImg);
                          },
                        )
                      : Image.file(File(widget.imageAssetPath),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                          return Image.network(defaultImg);
                        })),
            ),
          ),
        ),
      ),
    );
  }
}
