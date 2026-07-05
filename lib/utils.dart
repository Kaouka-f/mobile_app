import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
// import '../logging.dart';
import 'package:intl/intl.dart';
import 'package:kaouka/components/custom_elevated_button.dart';

import 'package:kaouka/core/shared_data.dart';
import 'package:kaouka/http/routes/get/get_msgs.dart';
import 'package:kaouka/http/routes/post/delete_msgs.dart';

Future<Position?> getCurrentLocation() async {
  try {
    final LocationPermission status = await Geolocator.checkPermission();
    if (status == LocationPermission.always &&
        status == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition();
      return position;
    } else {
      await Geolocator.requestPermission();
      return await Geolocator.getLastKnownPosition();
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    return null;
  }
}

void showPopUp(
    BuildContext context, String title, String message, VoidCallback onConfirm,
    {bool isDismissible = false}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Makes the dialog rectangle
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info, color: Colors.pinkAccent, size: 48),
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the pop-up
                      onConfirm();
                    },
                    text: isDismissible ? 'Oui' : 'Accept',
                  ),
                  isDismissible
                      ? CustomElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the pop-up
                          },
                          text: 'Non',
                          isIcon: false,
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 35, 35),
      );
    },
  );
}

enum FileType {
  audio,
  video,
  image,
  document,
  other,
  empty,
}

class FileTypeData {
  final FileType fileType;
  final String ext;
  FileTypeData({required this.fileType, required this.ext});
}

final audioExt = ['m4a', 'mp3', 'wav', 'aac', 'ogg', 'flac'];
final videoExt = ['mp4'];
final imageExt = ['jpg', 'jpeg', 'png'];
final documentExt = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'];

FileTypeData getFileType(String path) {
  String fileExtension = path.split('.').last;
  if (fileExtension.isNotEmpty && path.isNotEmpty) {
    if (audioExt.contains(fileExtension)) {
      return FileTypeData(fileType: FileType.audio, ext: fileExtension);
    } else if (videoExt.contains(fileExtension)) {
      return FileTypeData(fileType: FileType.video, ext: fileExtension);
    } else if (imageExt.contains(fileExtension)) {
      return FileTypeData(fileType: FileType.image, ext: fileExtension);
    } else if (documentExt.contains(fileExtension)) {
      return FileTypeData(fileType: FileType.document, ext: fileExtension);
    } else {
      return FileTypeData(fileType: FileType.other, ext: fileExtension);
    }
  }
  return FileTypeData(fileType: FileType.empty, ext: fileExtension);
}

List<String> stringListFromJson(String jsonString) {
  if (jsonString.isEmpty || jsonString == "[]") {
    return [];
  }
  String cleanedString = jsonString.replaceAll('[', '').replaceAll(']', '');
  List<String> elements = cleanedString.split(', ');
  List<String> stringList = elements.map((element) {
    return element.replaceAll("'", '');
  }).toList();
  return stringList;
}

String timestampToDate(String timestampIsoString) {
  String date = '';
  if (timestampIsoString != 'null' && timestampIsoString.isNotEmpty) {
    // Parse the ISO 8601 string, and automatically adapts to local timezone
    DateTime dateEn = DateTime.parse(timestampIsoString).toLocal();
    // Format the date to French locale format
    DateFormat dateFormat = DateFormat('EEEE d MMMM yyyy HH:mm:ss', 'fr_FR');
    date = dateFormat.format(dateEn);
  }
  return date;
}

String timestampUnixToDate(String timestampString) {
  String date = '';
  if (timestampString != 'null' && timestampString.isNotEmpty) {
    try {
      // Convert the string to a double (to handle fractional seconds)
      double timestamp = double.parse(timestampString);

      // Convert to milliseconds (since Dart expects milliseconds for Unix timestamps)
      DateTime dateEn =
          DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt())
              .toLocal();

      // Format the date to French locale format
      DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      date = dateFormat.format(dateEn);
    } catch (e) {
      print('Error parsing timestamp: $e');
    }
  }
  return date;
}

String encodeId(String id) {
  String encodedId = base64Url.encode(utf8.encode(id));
  return encodedId;
}

String decodeId1(String encodedId) {
  String decodedId = utf8.decode(base64Url.decode(encodedId));
  List<String> originalIds = decodedId.split('_');
  return originalIds[0];
}

String decodeId2(String encodedId) {
  String decodedId = utf8.decode(base64Url.decode(encodedId));
  // List<String> originalIds = decodedId.split('_');
  return decodedId;
}

String decodeId3(String encodedId) {
  String decodedId = utf8.decode(base64Url.decode(encodedId));
  List<String> originalIds = decodedId.split('_');
  return originalIds[1];
}

Future<void> handleMsg() async {
  SharedData sharedData = SharedData();
  String id = sharedData.getId;
  Map<String, dynamic> ret = {};
  if (id != "") {
    // HACK : firebase background do not work properly so use backend instead
    ret = await getMsgs(id, 0);
    while (ret["rest"] > 0) {
      ret = await getMsgs(id, ret["thold"]);
    }
    await deleteMsgs(id);
  }
}

void copyToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  // Show a snackbar or toast to indicate the text has been copied
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        'Texte copié dans le presse-papier',
        style: TextStyle(color: Colors.white),
      ),
    ),
  );
}

Future<String> showGallery() async {
  final picker = ImagePicker();
  final pickedXFile = await picker.pickImage(source: ImageSource.gallery);
  return pickedXFile!.path;
}
