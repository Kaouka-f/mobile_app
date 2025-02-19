import 'dart:async';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../logging.dart';

class NotificationComponent {
  static final NotificationComponent instance = NotificationComponent._();
  NotificationComponent._();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static int countBadge = 0;

  // TODO : ask for notif permission
  static Future<void> initializeNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      'app_icon',
    );

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestProvisionalPermission: true,
      requestCriticalPermission: true,
      defaultPresentList: true,
      // onDidReceiveLocalNotification: _handleReceiveNotification
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationClick,
        onDidReceiveBackgroundNotificationResponse:
            _handleBackgroundNotificationClick);
  }

  static Future<void> _handleNotificationClick(
      NotificationResponse payload) async {
    LoggerManager.logInfo('click on notification');
  }

  static Future<void> _handleBackgroundNotificationClick(
      NotificationResponse payload) async {
    LoggerManager.logInfo('click on background notification');
  }

  static Future<void> _handleReceiveNotification(
      int id, String? title, String? body, String? payload) async {
    LoggerManager.logInfo('receive on notification');
  }

  static String generateChannelId() {
    String baseId = 'kaouka';
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$baseId-$timestamp';
  }

  static int generateNotificationId() {
    Random random = Random();
    return random.nextInt(100000) + 1;
  }

  static Future<void> sendNotification(
      {required String title, required String body}) async {
    countBadge++;
    // int notificationId = generateNotificationId();
    // String id = generateChannelId();
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'kaouka',
      title,
      importance: Importance.max,
      priority: Priority.low,
    );

    final DarwinNotificationDetails initializationSettingsDarwin =
        DarwinNotificationDetails(
            badgeNumber: countBadge,
            presentBadge: null,
            threadIdentifier: "kaouka",
            categoryIdentifier: "kaouka");

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.show(
      10,
      title,
      body,
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }

  static Future<void> deleteBadge() async {
    // HACK: delete notif badge do not take effect the first time, need to send 4 delete before taking effect
    for (int i = 0; i != 4; i++) {
      try {
        await flutterLocalNotificationsPlugin.cancelAll();
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
        countBadge = 0;
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'kaouka',
          "",
          importance: Importance.max,
          priority: Priority.low,
        );
        const DarwinNotificationDetails initializationSettingsDarwin =
            DarwinNotificationDetails(
                badgeNumber: 0,
                presentBadge: null,
                threadIdentifier: "kaouka",
                categoryIdentifier: "kaouka");

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(
                iOS: initializationSettingsDarwin,
                android: androidPlatformChannelSpecifics);

        await flutterLocalNotificationsPlugin.show(
          10,
          '',
          '',
          platformChannelSpecifics,
          payload: 'notification_payload',
        );
      } catch (e) {
        LoggerManager.logError('fail to delete badge : $e');
      }
    }
  }
}
