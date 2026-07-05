import 'package:kaouka/core/database.dart';
import 'package:kaouka/http/http_manager.dart' show get;
import 'package:kaouka/models/message.dart';
import 'package:kaouka/notifiers/message_notifier.dart';

Future<Map<String, dynamic>> getMsgs(String id, int thold) async {
  final data = {
    'id': id,
    'thold': thold.toString(),
  };
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
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
