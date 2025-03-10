import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kaouka/database.dart';
import 'package:kaouka/message.dart';
import 'package:kaouka/notifiers/message_notifier.dart';
import 'package:kaouka/request.dart';
import 'package:kaouka/shared_data.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../logging.dart';
import 'dart:convert';
import 'person.dart';
import 'utils.dart';

const mode = String.fromEnvironment('MODE');

String host = mode == "TEST" ? "192.168.1.49" : "elaborium.site";
int port = 443;
bool secure = true;

// comment this line in production
// String host = '192.168.1.49';
// int port = 80;
// bool secure = false;

enum RequestType { get, post }

SecurityContext securityContext = SecurityContext.defaultContext;
final DatabaseHelper databaseHelper = DatabaseHelper.instance;

Future<String> sendRequestInsecure(
    RequestType type, Map<String, dynamic> queryParams, String path) async {
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

Future<String> sendRequestSecure(
    RequestType type, Map<String, dynamic> queryParams, String path) async {
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

Future<dynamic> get(Map<String, dynamic> queryParams, String path) async {
  try {
    String response;
    if (secure) {
      response = await sendRequestSecure(RequestType.get, queryParams, path);
    } else {
      response = await sendRequestInsecure(RequestType.get, queryParams, path);
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

Future<dynamic> post(Map<String, dynamic> data, String path) async {
  try {
    String response;
    if (secure) {
      response = await sendRequestSecure(RequestType.post, data, path);
    } else {
      response = await sendRequestInsecure(RequestType.post, data, path);
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

// GET

Future<List<ReqPerson>> getArrounds(String id, double long, double lat) async {
  String longStr = long.toString();
  String latStr = lat.toString();
  Map<String, dynamic> data = {'id': id, 'long': longStr, 'lat': latStr};
  final res = await get(data, "getArrounds");
  List<ReqPerson> requests = [];
  try {
    if (res != null) {
      res.forEach((key, value) {
        requests.add(ReqPerson(
          person: Person(
            id: value['id'].toString(),
            name: value['name'] ?? "undefined",
            img: value['picture'] != ""
                ? value['picture'].toString()
                : "https://elaborium.site/proxy/stream/default/profile.jpg",
            scale: double.parse(value['scale'] ?? "1.0"),
            offsetX: double.parse(value['offsetX'] ?? "0.0"),
            offsetY: double.parse(value['offsetY'] ?? "0.0"),
            connected: value['connected'] == "true",
          ),
          request: Request.fromJson(value['requests']),
          dist: value['distance'].toString(),
        ));
      });
    }
  } catch (e) {
    if (kDebugMode) print(e);
  }
  return requests;
}

Future<Person> getInfos(String id) async {
  Person people;
  Map<String, dynamic> data = {'personid': id};
  final res = await get(data, "getInfos");
  people = (Person(
    id: id,
    name: res['name'] ?? "undefined",
    img:
        res['img'] ?? "https://elaborium.site/proxy/stream/default/profile.jpg",
    scale: double.parse(res['scale'] ?? "0.0"),
    offsetX: double.parse(res['offsetX'] ?? "0.0"),
    offsetY: double.parse(res['offsetY'] ?? "0.0"),
    connected: res['connected'] == "true",
  ));
  return people;
}

Future<dynamic> retrieveId() async {
  Map<String, dynamic> data = {};
  final res = await get(data, "getId");
  return {"id": res['id'], "privateId": res['privateid']};
}

Future<bool> isPayed(String id) async {
  Map<String, dynamic> data = {'id': id};
  final res = await get(data, "isPayed");
  if (res == 'payed') {
    return false;
  }
  return true;
}

Future<bool> connect(String id) async {
  Map<String, dynamic> data = {'id': id};
  final res = await post(data, "connect");
  print(res);
  if (res["connection"] == 'sucess') {
    return false;
  }
  return true;
}

Future<bool> signUp(String id, String password, String email) async {
  Map<String, dynamic> data = {'id': id, 'password': password, 'email': email};
  final res = await get(data, "signUp");
  if (res.toString() == 'signed') {
    return false;
  }
  return true;
}

Future<List<ReqPerson>> getComments(String id, String lastReqId) async {
  List<ReqPerson> requests = [];
  Map<String, dynamic> data = {'id': id, 'lastReqId': lastReqId};
  final res = await get(data, "getComments");
  try {
    if (res != null) {
      res.forEach((key, value) {
        requests.add(ReqPerson(
          person: Person(
            id: value['id'].toString(),
            name: value['name'] ?? "undefined",
            img: value['picture'] != ""
                ? value['picture'].toString()
                : "https://elaborium.site/proxy/stream/default/profile.jpg",
            scale: double.parse(value['scale'] ?? "1.0"),
            offsetX: double.parse(value['offsetX'] ?? "0.0"),
            offsetY: double.parse(value['offsetY'] ?? "0.0"),
            connected: value['connected'] == "true",
          ),
          request: Request.fromJson(value),
          dist: value['distance'].toString(),
        ));
      });
    }
  } catch (e) {
    if (kDebugMode) print(e);
  }
  return requests;
}

Future<dynamic> getOwnReqs(String id, String lastReqId) async {
  SharedData shared = SharedData();
  List<ReqPerson> requests = [];
  final data = {
    'id': id,
    'lastReqId': lastReqId,
  };
  final res = await get(data, "getOwnReqs");
  try {
    if (res != null) {
      res.forEach((key, value) {
        requests.add(ReqPerson(
          person: Person(
            id: decodeId1(shared.id),
            name: shared.name,
            img: shared.imageUrl,
            scale: shared.imageScale,
            offsetX: shared.imageOffset.dx,
            offsetY: shared.imageOffset.dy,
            connected: false,
          ),
          request: Request.fromJson(value),
          dist: '',
        ));
      });
    }
  } catch (e) {
    if (kDebugMode) print(e);
  }
  // requests = Request.jsonToList(res);
  return requests;
}

Future<dynamic> getInterressed(String id, String lastReqId) async {
  SharedData shared = SharedData();
  List<ReqPerson> requests = [];
  final data = {
    'id': id,
    'lastReqId': lastReqId,
  };
  final res = await get(data, "getInterressed");
  try {
    if (res != null) {
      res.forEach((key, value) {
        requests.add(ReqPerson(
          person: Person(
            id: decodeId1(shared.id),
            name: shared.name,
            img: shared.imageUrl,
            scale: shared.imageScale,
            offsetX: shared.imageOffset.dx,
            offsetY: shared.imageOffset.dy,
            connected: false,
          ),
          request: Request.fromJson(value),
          dist: '',
        ));
      });
    }
  } catch (e) {
    if (kDebugMode) print(e);
  }
  // requests = Request.jsonToList(res);
  return requests;
}

Future<dynamic> getLikes(String reqId) async {
  final data = {
    'reqId': reqId,
  };
  final res = await get(data, "getLikes");
  return res['likes'];
}

Future<List<ReqPerson>> getAllReqs(Person person, String lastReqId) async {
  List<ReqPerson> posts = [];
  final data = {'id': person.id, 'lastReqId': lastReqId};
  final res = await get(data, "getAllReqs");
  if (res != null) {
    res.forEach((key, value) {
      Request req = Request.fromJson(value);
      posts.add(ReqPerson(person: person, request: req, dist: ""));
    });
  }
  return posts;
}

Future<ReqPerson?> getRequest(String reqId) async {
  ReqPerson request;
  final data = {
    'reqId': reqId,
  };
  final res = await get(data, "getRequest");
  try {
    if (res != null) {
      request = ReqPerson(
          person: Person(
            id: res['id'].toString(),
            name: res['name'] ?? "undefined",
            img: res['picture'] != ""
                ? res['picture'].toString()
                : "https://elaborium.site/proxy/stream/default/profile.jpg",
            scale: double.parse(res['scale'] ?? "1.0"),
            offsetX: double.parse(res['offsetX'] ?? "0.0"),
            offsetY: double.parse(res['offsetY'] ?? "0.0"),
            connected: res['connected'] == "true",
          ),
          request: Request.fromJson(res),
          dist: "");
    } else {
      return null;
    }
  } catch (e) {
    if (kDebugMode) print('get req error : $e');
    return null;
  }
  return request;
}

Future<dynamic> getFeed(String id) async {
  final data = {
    'id': id,
  };
  final res = await get(data, "getFeed");
  return res;
}

Future<Map<String, dynamic>> getMsgs(String id, int thold) async {
  final data = {
    'id': id,
    'thold': thold.toString(),
  };
  final res = await get(data, "getMsgs");
  res['msgs'].forEach((key, value) {
    if (value.isNotEmpty) {
      String personId = value['personId'];
      String messageS = value['message'] ?? "";
      String media = value['media'] ?? "";
      String timestamp = value['ts'] ?? "";
      if (personId.isNotEmpty && timestamp.isNotEmpty) {
        double timestampToDouble = double.parse(timestamp) * 1000;
        DateTime dateTimeWithTimezone = DateTime.fromMillisecondsSinceEpoch(
          timestampToDouble.toInt(),
          isUtc: true,
        );
        // HACK receiving firebase message twice
        // TODO get last timestamp in db if timestamp < last timestamp + 5milisec // do nothing
        databaseHelper.insertMessage(
            dateTimeWithTimezone.toString(), messageS, personId, false, media);
        // NotificationComponent.sendNotification(title: 'Kaouka', body: messageS);
        MessageNotifier.instance.addCustomMessage(
          CustomMessage(
              isSentByUser: false,
              message: messageS,
              timestamp: dateTimeWithTimezone.toString(),
              personId: personId,
              filepath: media,
              read: false),
        );
      }
    }
  });
  return {"rest": res["rest"], "thold": res["thold"]};
}

// POST

Future<dynamic> postRequest(String id, String request, File file) async {
  final data = {
    "id": id,
    "request": request,
  };
  dynamic res = await sendFile(data, file, "postReq");
  return res;
}

Future<void> postNotifToken(String id, String notifToken) async {
  final data = {
    "id": id,
    "notifToken": notifToken,
  };
  final res = post(data, "postNotifToken");
  if (res.toString() == "true") {
    // TODO: handle error
  }
}

Future<void> postName(String id, String name) async {
  final data = {
    "id": id,
    "name": name,
  };
  final res = post(data, "postName");
  if (res.toString() == "true") {
    // TODO: handle error
  }
}

Future<String> postPP(String id, String imgUrl) async {
  final data = {
    "id": id,
  };
  return await sendFile(data, File(imgUrl), "postPP");
}

Future<void> postPPSetting(
    String id, double scale, double offsetX, double offsetY) async {
  final data = {
    "id": id,
    "scale": scale.toString(),
    "offsetX": offsetX.toString(),
    "offsetY": offsetY.toString(),
  };
  final res = post(data, "postPPSetting");
  if (res.toString() == "true") {
    // TODO: handle error
  }
}

Future<void> visible(String id, String value) async {
  final data = {'id': id, 'value': value};
  final res = post(data, "visible");
  if (res.toString() == "true") {
    // TODO: handle error
  }
}

Future<dynamic> onConnection(String id) async {
  final data = {'id': id};
  final res = await post(data, "onConnection");
  return res;
}

Future<dynamic> onDisconnection(String id) async {
  final data = {'id': id};
  final res = await post(data, "onDisconnection");
  return res;
}

Future<dynamic> paying(String id, String payId) async {
  final data = {
    'id': id,
    'payId': payId,
  };
  final res = post(data, "paying");
  return res;
}

Future<bool> updateReq(String id, String reqId, String newReq) async {
  final data = {
    'id': id,
    'reqId': reqId,
    'newReq': newReq,
  };
  final res = await post(data, "updateReq");
  return res;
}

Future<dynamic> deleteReq(String id, String reqId) async {
  final data = {
    'id': id,
    'reqId': reqId,
  };
  final res = post(data, "deleteReq");
  return res;
}

Future<dynamic> deleteInterressed(String id, String reqId) async {
  final data = {
    'id': id,
    'reqId': reqId,
  };
  final res = post(data, "deleteInterressed");
  return res;
}

Future<dynamic> postComments(
    String id, String postId, String comment, File file) async {
  final data = {
    'id': id,
    'postId': postId,
    'comment': comment,
  };
  final res = await sendFile(data, file, "postComments");
  return res;
}

Future<dynamic> likeReq(String id, String reqId) async {
  final data = {'id': id, 'reqId': reqId};
  final res = await post(data, "likeReq");
  return res;
}

// Future<dynamic> deleteAccount(String id, String email, String password) async {}
Future<dynamic> deleteAcnt(String id) async {
  final data = {
    'id': id,
  };
  final res = post(data, "deleteAccount");
  return res;
}

Future<dynamic> signalReq(String id, String reqId) async {
  final data = {
    'id': id,
    'reqId': reqId,
  };
  final res = post(data, "signal_request");
  return res;
}

Future<dynamic> sendMsg(
    String personId, String targetPersonId, String message, File file) async {
  String filepath = '';
  final data = {
    'personId': personId,
    'targetPersonId': targetPersonId,
    'message': message,
    // 'filename': file.path.isNotEmpty ? file.path.split('.').last : ''
  };
  // dynamic res = await sendFile(data, file, "sendMsg");
  dynamic res = await post(data, "sendMsg");
  if (res['media'] != null) {
    filepath = res['media'];
  }
  print(res);
  if (res['result'] == "true") {
    final DatabaseHelper databaseHelper = DatabaseHelper.instance;
    DateTime currentTimeUtc = DateTime.now().toUtc();
    String timestampIsoString = currentTimeUtc.toIso8601String();
    databaseHelper.insertMessage(
        timestampIsoString, message, targetPersonId, true, filepath);
    return {true, res['media']};
  } else if (res['result'] == "blocked") {
    return {false, "blocked"};
  }
  return {false, ""};
}

Future<void> deleteMsgs(String id) async {
  final data = {'id': id};
  await post(data, "deleteMsgs");
}

Future<dynamic> deleteMsg(String id, String media) async {
  final data = {'id': id, 'media': media};
  dynamic res = await post(data, "deleteMsg");
  return res['result'];
}

Future<dynamic> blockedUser(String id, String userId) async {
  final data = {'id': id, 'userId': userId};
  dynamic res = await post(data, "blockUser");
  return res['result'];
}

Future<dynamic> isBlocked(String id, String userId) async {
  final data = {'id': id, 'userId': userId};
  dynamic res = await get(data, "isBlocked");
  return res['result'];
}

Future<dynamic> getBots() async {
  final data = {'password': 'zigzag'};
  return await get(data, "getBots");
}

Future<dynamic> postLocation(String id, double long, double lat) async {
  final data = {'id': id, 'long': long, 'lat': lat};
  dynamic res = await post(data, "postLocation");
  return res['result'];
}

Future<dynamic> createBot(
    String id,
    String privateId,
    String name,
    String img,
    double scale,
    double offsetX,
    double offsetY,
    double longitude,
    double latitude) async {
  final data = {
    'id': id,
    'privateId': privateId,
    'name': name,
    'imgUrl': img,
    'scale': scale,
    'offsetX': offsetX,
    'offsetY': offsetY,
    'lng': longitude,
    'lat': latitude,
    'password': 'zigzag'
  };
  return await post(data, "createBot");
}
