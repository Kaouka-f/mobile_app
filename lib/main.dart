import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kaouka/models/bot.dart';
import 'package:kaouka/core/database.dart';
import 'package:kaouka/pages/login/connect.dart';
import 'package:kaouka/pages/login/login_page.dart';
import 'package:kaouka/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifiers/mode_notifier.dart';
import 'notifiers/person_notifier.dart';
import 'notifiers/visible_notifier.dart';
import 'core/shared_data.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'notifiers/image_notifier.dart';
import 'notifiers/message_notifier.dart';
import 'pages/home_page.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/logging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;

SharedData sharedData = SharedData();
const platform = MethodChannel('com.elaborium.kaouka/channel');
String jwt = "";
Future<String?> getToken() async {
  try {
    SharedData sharedData = SharedData();
    String? token = await FirebaseMessaging.instance.getToken();
    sharedData.setNotifToken = token!;
    return token;
  } catch (e) {
    LoggerManager.logInfo('error token firebase: $e');
  }
  return null;
}

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // await Firebase.initializeApp();
// }

Future<void> _invokeNativeMethod() async {
  try {
    final result = await platform.invokeMethod('getId');
    if (kDebugMode) {
      print("Result from Flutter method: $result");
    }
  } on PlatformException catch (e) {
    if (kDebugMode) {
      print("Failed to invoke method: '${e.message}'.");
    }
  }
}

Future<String> _handleMethodCall(MethodCall call) async {
  switch (call.method) {
    case 'getId':
      String id = sharedData.getId;
      return id;
    default:
      throw MissingPluginException();
  }
}

void _registerMethodChannel() {
  platform.setMethodCallHandler(_handleMethodCall);
}

// permission
Future<void> notifPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

// Firebase message
String messageIdSem = "";

// Background
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  var timeout = task.timeout;
  if (timeout) {
    LoggerManager.logError(
        "[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  LoggerManager.logError("[BackgroundFetch] Headless event received: $taskId");

  var timestamp = DateTime.now();

  var prefs = await SharedPreferences.getInstance();

  // Read fetch_events from SharedPreferences
  var events = <String>[];
  var json = prefs.getString("fetch_events");
  if (json != null) {
    events = jsonDecode(json).cast<String>();
  }
  // Add new event.
  events.insert(0, "$taskId@$timestamp [Headless]");
  // Persist fetch events in SharedPreferences
  prefs.setString("fetch_events", jsonEncode(events));

  if (taskId == 'com.transistorsoft.kaouka.task') {
    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.kaouka.task",
        delay: 5000,
        periodic: false,
        forceAlarmManager: false,
        stopOnTerminate: false,
        enableHeadless: true));
  }
  BackgroundFetch.finish(taskId);
}

Future<void> main() async {
  const bool selector = bool.fromEnvironment('SELECTOR', defaultValue: false);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // HACK state management in flutter loop
  LoggerManager.setupLogging();
  await sharedData.init();
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;

  // JWT
  final storage = FlutterSecureStorage();
  jwt = await storage.read(key: 'persistent_token') ?? '';

  // databaseHelper.recreateDatabase();
  if (Platform.isAndroid) {
    _registerMethodChannel();
    _invokeNativeMethod();
  }
  // push notifications
  String? token = await FirebaseMessaging.instance.getToken();
  sharedData.setNotifToken = token!;
  FirebaseMessaging.onMessage.listen((RemoteMessage messageS) {
    // HACK firebase onMessage triggered 2 times
    if (messageIdSem != messageS.messageId) {
      handleMsg();
    }
    messageIdSem = messageS.messageId!;
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    // TODO: should open the good page
  });
  notifPermission();
  initializeDateFormatting('fr', null).then((_) {
    runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider<PersistentVisibleProvider>(
            create: (_) => PersistentVisibleProvider()),
        ChangeNotifierProvider<PersistentModeProvider>(
            create: (_) => PersistentModeProvider()),
        ChangeNotifierProvider<PeopleNotifier>(create: (_) => PeopleNotifier()),
        ChangeNotifierProvider<MessageNotifier>(
            create: (_) => MessageNotifier()),
        ChangeNotifierProvider<PersistentImageProvider>(
            create: (_) => PersistentImageProvider()),
        ChangeNotifierProvider<PeopleNotifier>(create: (_) => PeopleNotifier()),
      ], child: const MyApp()),
    );
  });
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    PersistentModeProvider darkMode =
        // ignore: use_build_context_synchronously
        Provider.of<PersistentModeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkMode.isModeChanged ? lightStyle : darkStyle,
      // home: const HomePage(),
      home: jwt.isNotEmpty ? const HomePage() : const ConnectPage(),
    );
  }
}
