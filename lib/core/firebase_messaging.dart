import '../notifiers/message_notifier.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'logging.dart';
import 'shared_data.dart';

class FirebaseMessagingService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  SharedData sharedData = SharedData();
  final MessageNotifier newMessageNotifier = MessageNotifier();

  Future<void> configureFirebaseMessaging() async {
    try {
      await firebaseMessaging.requestPermission();
      String? token = await getToken();
      LoggerManager.logInfo('firebase token = $token');
    } catch (e) {
      LoggerManager.logInfo('error while configuring firebase : $e');
    }
  }

  Future<String?> getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      sharedData.setNotifToken = token!;
      return token;
    } catch (e) {
      LoggerManager.logInfo('error token firebase: $e');
    }
    return null;
  }

  Future<void> deleteFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    try {
      await messaging.deleteToken();
      print("FCM Token deleted successfully.");
    } catch (e) {
      print("Error deleting FCM token: $e");
    }
  }
}
