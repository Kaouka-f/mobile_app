import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileDownloader {
  final Dio _dio = Dio();

  // Function to download and save the file
  Future<String?> downloadFile(String url, String fileName) async {
    try {
      // Request storage permission (optional, only for Android/iOS)
      if (await Permission.storage.request().isGranted) {
        // Get the directory to save the file
        Directory? directory =
            await getExternalStorageDirectory(); // For Android, iOS use getApplicationDocumentsDirectory

        if (directory != null) {
          String filePath = '${directory.path}/$fileName';

          // Download the file
          await _dio.download(url, filePath, onReceiveProgress: (count, total) {
            if (kDebugMode) {
              print(
                  'Downloading: ${(count / total * 100).toStringAsFixed(0)}%');
            }
          });
          if (kDebugMode) {
            print('File downloaded to: $filePath');
          }
          return filePath; // Return the file path after successful download
        } else {
          if (kDebugMode) {
            print('Unable to access storage.');
          }
          return null; // Return null if storage directory is unavailable
        }
      } else {
        if (kDebugMode) {
          print('Permission denied.');
        }
        return null; // Return null if permission is denied
      }
    } catch (e) {
      if (kDebugMode) {
        print('Download failed: $e');
      }
      return null; // Return null if there is any error during download
    }
  }
}
