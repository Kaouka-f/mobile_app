import 'package:kaouka/utils.dart';

class Request {
  final String reqId;
  final String request;
  final String media;
  final String reqTime;
  final int signalNb;
  final int likeNb;
  final int commentNb;
  final List<String> likes;
  const Request({
    required this.reqId,
    required this.request,
    required this.reqTime,
    this.commentNb = 0,
    this.likeNb = 0,
    this.signalNb = 0,
    this.likes = const [],
    this.media = '',
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      reqId: json['reqId'] ?? json['commentId'] ?? '',
      request: json['text'] ?? json['comment'] ?? '',
      media: (json['media'].toString().isNotEmpty && json['media'] != null)
          ? json['media']
          : '',
      reqTime: json['reqTime'] ?? json['ts'] ?? '',
      commentNb: int.parse(json['commentNb'] ?? '0'),
      likeNb: int.parse(json['likeNb'] ?? '0'),
      signalNb: int.parse(json['signalNb'] ?? '0'),
      likes: stringListFromJson(json['likes'] ?? '[]'),
    );
  }

  static List<Request> jsonToList(Map<String, dynamic> json) {
    List<Request> requests = [];
    json.forEach(
      (key, value) => requests.add(
        Request(
          reqId: value["reqId"],
          request: value["text"],
          media:
              (value['media'].toString().isNotEmpty && value['media'] != null)
                  ? value['media']
                  : '',
          reqTime: value['reqTime'],
          commentNb: int.parse(value['commentNb'] ?? '0'),
          likeNb: int.parse(value['likeNb'] ?? '0'),
          signalNb: int.parse(value['signalNb'] ?? '0'),
          likes: stringListFromJson(value['likes']),
        ),
      ),
    );
    return requests;
  }
}
