import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kaouka/core/authService.dart';
import 'package:kaouka/core/database.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../core/logging.dart';
import 'dart:convert';

const mode = String.fromEnvironment('MODE');

// String host = mode == "TEST" ? "192.168.1.100" : "elaborium.site";
// int port = 443;
// bool secure = true;

// comment this line in production
String host = '192.168.1.14';
int port = 8000;
bool secure = false;

enum RequestType { get, post }

SecurityContext securityContext = SecurityContext.defaultContext;
final DatabaseHelper databaseHelper = DatabaseHelper.instance;

Future<String> sendRequestInsecure(RequestType type,
    Map<String, dynamic> queryParams, String path, bool withAuth) async {
  final HttpClient httpClient = HttpClient();

  try {
    final Uri url = Uri(
      scheme: "http", // Use "http" for unsecured HTTP
      host: host,
      port: port,
      queryParameters: (type == RequestType.get) ? queryParams : null,
      path: '/proxy/$path',
    );
    final HttpClientRequest request = (type == RequestType.get)
        ? await httpClient.getUrl(url)
        : await httpClient.postUrl(url);

    if (withAuth) {
      AuthService authService = AuthService();
      final token = authService.sessionToken;
      if (token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
    }

    if (type == RequestType.post) {
      request.headers.set(
          HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      // final dataEmoji = jsonEncodeWithEmojiSupport(queryParams);
      final requestDataJson = jsonEncode(queryParams);
      request.write(requestDataJson);
    }

    final HttpClientResponse response = await request.close();

    if (response.statusCode == HttpStatus.ok) {
      // Successful response, parse and handle the data here
      final responseBody = await response.transform(utf8.decoder).join();
      return responseBody;
    } else {
      // Error handling for unsuccessful response
      LoggerManager.logInfo(
          'Request failed with status  Insecure: ${response.statusCode}');
      if (kDebugMode) {
        print('Request failed with status  Insecure: ${response.statusCode}');
      }
    }
  } catch (e) {
    LoggerManager.logInfo('Request failed  Insecure: $e');
    if (kDebugMode) {
      print('Request failed Insecure: $e');
    }
  } finally {
    httpClient.close(); // Close the HttpClient when done
  }

  return "";
}

Future<String> sendRequestSecure(RequestType type,
    Map<String, dynamic> queryParams, String path, bool withAuth) async {
  // Create a custom HttpClient with the custom security context
  final HttpClient httpClient = HttpClient(context: securityContext);
  // Make an HTTPS request using the custom HttpClient
  try {
    // final Uri url = Uri.parse('https://elaborium.site/proxy');
    final Uri url = Uri(
        scheme: "https",
        host: host,
        port: port,
        queryParameters: type == RequestType.get ? queryParams : null,
        path: '/proxy/$path');

    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      //  TODO: add some check in certificate
      return true;
    };
    final HttpClientRequest request = type == RequestType.get
        ? await httpClient.getUrl(url)
        : await httpClient.postUrl(url);

    if (withAuth) {
      AuthService authService = AuthService();
      final token = authService.sessionToken;
      if (token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
    }

    if (type == RequestType.post) {
      request.headers.set(
          HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      // final dataEmoji = jsonEncodeWithEmojiSupport(queryParams);
      final requestDataJson = jsonEncode(queryParams);
      request.write(requestDataJson);
    }

    final HttpClientResponse response = await request.close();

    if (response.statusCode == HttpStatus.ok) {
      // Successful response, parse and handle the data here
      final responseBody = await response.transform(utf8.decoder).join();
      return responseBody;
    } else {
      // Error handling for unsuccessful response
      LoggerManager.logInfo(
          'Request $queryParams failed with status: ${response.statusCode}');
      if (kDebugMode) {
        print('Request failed with status: ${response.statusCode}');
      }
    }
  } catch (e) {
    LoggerManager.logInfo('request failed:  $e');
    if (kDebugMode) {
      print('request failed:  $e');
    }
    return "";
  }
  return "";
}

String jsonEncodeWithEmojiSupport(Object object) {
  const encoder = JsonEncoder.withIndent(' ');
  final encoded = encoder.convert(object);
  final runes = encoded.runes;
  final characters = runes.map((rune) {
    final character = String.fromCharCode(rune);
    // Check if the character is outside the ASCII range
    if (rune < 32 || rune > 126) {
      // Convert the character to a Unicode escape sequence
      return '\\u${rune.toRadixString(16).padLeft(4, '0')}';
    }
    return character;
  });
  return characters.join('');
}

Future<dynamic> get(Map<String, dynamic> queryParams, String path,
    {bool withAuth = false}) async {
  try {
    String response;
    if (secure) {
      response =
          await sendRequestSecure(RequestType.get, queryParams, path, withAuth);
    } else {
      response = await sendRequestInsecure(
          RequestType.get, queryParams, path, withAuth);
    }
    if (response.isNotEmpty) {
      Map<String, dynamic> jsonData = jsonDecode(response);
      return jsonData;
    }
  } catch (error) {
    LoggerManager.logInfo('Error occurred: $error');
    if (kDebugMode) {
      print('Get Error occurred $path : $error');
    }
    return {};
  }
}

Future<dynamic> post(Map<String, dynamic> data, String path,
    {bool withAuth = false}) async {
  try {
    String response;
    if (secure) {
      response =
          await sendRequestSecure(RequestType.post, data, path, withAuth);
    } else {
      response =
          await sendRequestInsecure(RequestType.post, data, path, withAuth);
    }
    if (response.isNotEmpty) {
      dynamic jsonData = jsonDecode(response);
      return jsonData;
    }
  } catch (error) {
    LoggerManager.logInfo('Error occurred: $error');
    if (kDebugMode) {
      print('Post Error occurred $path : $error');
    }
    print('Post Error occurred $path : $error');
    return {};
  }
}

Future<http.StreamedResponse> sendFiles(
    Map<String, dynamic> data, List<File> files, String path) async {
  try {
    final Uri uri = Uri(
      scheme: "https",
      host: host,
      port: port,
      queryParameters: data,
      path: path,
    );

    var request = http.MultipartRequest('POST', uri);

    // Files
    await Future.forEach(
      files,
      (file) async => {
        request.files.add(
          http.MultipartFile(
            'files',
            file.readAsBytes().asStream(),
            file.lengthSync(),
            filename: file.path.split('/').last,
            contentType: MediaType.parse(
                lookupMimeType(file.path) ?? 'application/octet-stream'),
          ),
        )
      },
    );

    return await request.send();
  } catch (err) {
    if (kDebugMode) print(err);
    return http.StreamedResponse(const Stream.empty(), 500);
  }
}

Future<dynamic> sendFile(
    Map<String, dynamic> data, File file, String path) async {
  try {
    final Uri uri = Uri(
      scheme: secure ? "https" : "http",
      host: host,
      port: port,
      queryParameters: data,
      path: '/proxy/$path',
    );

    var request = http.MultipartRequest('POST', uri);

    // JWT
    AuthService authService = AuthService();
    final token = authService.sessionToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Files
    if (file.path.isNotEmpty) {
      request.files.add(
        http.MultipartFile(
          'file',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split('/').last,
          contentType: MediaType.parse(
              lookupMimeType(file.path) ?? 'application/octet-stream'),
        ),
      );
    }

    final response = await request.send();
    final responseDecode = await response.stream.bytesToString();
    return responseDecode;
  } catch (err) {
    if (kDebugMode) print('send file err: $err');
    return jsonEncode({'host': 'unset'});
  }
}
