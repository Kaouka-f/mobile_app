import 'dart:convert';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:kaouka/components/badge_icon.dart';
import 'package:kaouka/components/input_bar.dart';
import 'package:kaouka/database.dart';
import 'package:kaouka/notifiers/message_notifier.dart';
import 'package:kaouka/notifiers/visible_notifier.dart';
import 'package:kaouka/pages/deep_link_request_page.dart';
import 'package:kaouka/pages/user_menu.dart';
import 'package:kaouka/person.dart';
import 'package:kaouka/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../notifiers/mode_notifier.dart';
import '../components/cgu_.dart';
import 'lost_connection_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifications.dart';
import '../notifiers/image_notifier.dart';
import '../shared_data.dart';
import '../utils.dart';
import 'arround_page.dart';
import 'profile_page.dart';
import 'extra_page.dart';
import 'contact_page.dart';
import 'dart:async';
import '../http_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../logging.dart';

enum AppState { connected, disconnected }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

const bool selector = bool.fromEnvironment('SELECTOR', defaultValue: false);

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool isMenuOpen = false;
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final TextEditingController _textEditingController = TextEditingController();
  SharedData sharedData = SharedData();
  String imageUrl = "https://elaborium.site/proxy/stream/default/profile.jpg";
  double imageScale = 1.0;
  Offset imageOffset = const Offset(0, 0);
  bool lostConnection = false;
  late bool isToggled;
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  int notifCount = 0;
  var appState = AppState.disconnected;
  bool setup = false;

  final List<Widget> _pages = [
    const ArroundPage(),
    const ExtraPage(),
    const ContactPage(),
    const ProfilePage(),
  ];

  openDeepLink(String linkId) async {
    if (linkId != "") {
      ReqPerson? request = await getRequest(linkId);
      if (request != null) {
        bool isOwn = (linkId == decodeId1(sharedData.getId));
        showModalBottomSheet(
          // ignore: use_build_context_synchronously
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: DeepLinkHandler(
                  request: request,
                  isOwn: isOwn,
                ));
          },
        );
      } else {
        showModalBottomSheet(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: const Text("Contenu non disponible"));
          },
        );
      }
    }
  }

  Future<void> _submit(File file) async {
    if (_textEditingController.text.isNotEmpty || file.path.isNotEmpty) {
      final res = await postRequest(
          sharedData.getId, _textEditingController.text, file);
      bool ret = false;
      if (res.toString().contains('res')) {
        final resDecode = json.decode(res);
        if (resDecode['res'] == 'false') {
          _textEditingController.clear();
          setState(() {
            isWritingPost = false;
          });
        } else {
          ret = true;
        }
      } else {
        ret = true;
      }
      if (ret) {
        // ignore: use_build_context_synchronously
        showPopUp(context, "Erreur",
            "Une erreur est survenue lors de l'envoie du post", () => ());
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (appState == AppState.disconnected &&
        state == AppLifecycleState.resumed) {
      appState = AppState.connected;
      LoggerManager.logInfo('resumed');
      Future.delayed(const Duration(seconds: 5));
      if (Platform.isIOS) await onConnection(sharedData.getId);
    } else if (appState == AppState.connected &&
        (state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden ||
            state == AppLifecycleState.detached)) {
      appState = AppState.disconnected;
      LoggerManager.logInfo('paused');
      Future.delayed(const Duration(seconds: 5));
      if (Platform.isIOS) await onDisconnection(sharedData.getId);
    }
  }

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  bool floatingButtonTop = false;
  bool floatingButtonLeft = false;
  void onSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    // Detect swipe direction
    if (details.primaryVelocity! > 0) {
      setState(() {
        // Swiped Right ➡️
        if (floatingButtonTop) {
          floatingButtonPos = FloatingActionButtonLocation.endTop;
        } else {
          floatingButtonPos = FloatingActionButtonLocation.endFloat;
        }
        floatingButtonLeft = false;
      });
    } else {
      // Swiped Left ⬅️
      setState(() {
        if (floatingButtonTop) {
          floatingButtonPos = FloatingActionButtonLocation.centerTop;
        } else {
          floatingButtonPos = FloatingActionButtonLocation.centerFloat;
        }
        floatingButtonLeft = true;
      });
    }
  }

  void onVerticalSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! > 0) {
      setState(() {
        // Swiped Down ⬇️
        if (floatingButtonLeft) {
          floatingButtonPos = FloatingActionButtonLocation.centerFloat;
        } else {
          floatingButtonPos = FloatingActionButtonLocation.endFloat;
        }
        floatingButtonTop = false;
      });
    } else {
      setState(() {
        // Swiped Up ⬆️
        if (floatingButtonLeft) {
          floatingButtonPos = FloatingActionButtonLocation.centerTop;
        } else {
          floatingButtonPos = FloatingActionButtonLocation.endTop;
        }
        floatingButtonTop = true;
      });
    }
  }

  getContactsNotif() async {
    setState(() {
      notifCount = MessageNotifier.instance.messagenb;
    });
  }

  String linkId = "";
  final appLinks = AppLinks();
  init() async {
    // dynamic link handler
    appLinks.uriLinkStream.listen((uri) {
      linkId = uri.queryParameters['id']!;
      openDeepLink(linkId);
    });
    // set id
    await Future.delayed(const Duration(seconds: 1));
    // set last connection server side
    onConnection(sharedData.getId);

    // push notif
    NotificationComponent.deleteBadge();
    // background
    await Future.delayed(const Duration(seconds: 2));
    BackgroundFetch.start().then((int status) {
      LoggerManager.logInfo('[BackgroundFetch] start success: $status');
    });
    await handleMsg();
  }

  lostConn(List<ConnectivityResult> result) async {
    setState(() {
      _connectivityResult = result;
      if (_connectivityResult == ConnectivityResult.none) {
        lostConnection = true;
      } else {
        lostConnection = false;
      }
    });
  }

  late List<ConnectivityResult> _connectivityResult;
  final Connectivity _connectivity = Connectivity();
  // late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    print('selector: $selector');
    // initPlatformState();
    MessageNotifier.instance.addListener(getContactsNotif);
    // _connectivitySubscription =
    _connectivity.onConnectivityChanged.listen(lostConn);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!sharedData.generalCondition) {
        showPopUp(context, generalConditionTitle, generalConditionMessage, () {
          sharedData.setGeneralCondition = true;
        });
      }
      init();
    });
    WidgetsBinding.instance.addObserver(this);
    BackgroundFetch.stop().then((status) {
      LoggerManager.logError('[BackgroundFetch] stop success: $status');
    });
    BackgroundFetch.start().then((status) {
      LoggerManager.logError('[BackgroundFetch] start success: $status');
    }).catchError((e) {
      LoggerManager.logError('[BackgroundFetch] start FAILURE: $e');
    });
  }

  List<String> _events = [];

  Future<void> initPlatformState() async {
    // Load persisted fetch events from SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    var json = prefs.getString("fetch_events");
    if (json != null) {
      setState(() {
        _events = jsonDecode(json).cast<String>();
      });
    }

    // Configure BackgroundFetch.
    try {
      var status = await BackgroundFetch.configure(
          BackgroundFetchConfig(
            minimumFetchInterval: 15,
            forceAlarmManager: false,
            stopOnTerminate: false,
            startOnBoot: true,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            // requiredNetworkType: NetworkType.NONE
          ),
          _onBackgroundFetch,
          _onBackgroundFetchTimeout);
      LoggerManager.logError('[BackgroundFetch] configure success: $status');

      // Schedule a "one-shot" custom-task in 10000ms.
      // These are fairly reliable on Android (particularly with forceAlarmManager) but not iOS,
      // where device must be powered (and delay will be throttled by the OS).
      BackgroundFetch.scheduleTask(TaskConfig(
          taskId: "com.transistorsoft.kaouka.task",
          delay: 10000,
          periodic: false,
          forceAlarmManager: true,
          stopOnTerminate: false,
          enableHeadless: true));
    } on Exception catch (e) {
      LoggerManager.logError("[BackgroundFetch] configure ERROR: $e");
    }

    if (!mounted) return;
  }

  void _onBackgroundFetch(String taskId) async {
    var prefs = await SharedPreferences.getInstance();
    var timestamp = DateTime.now();
    // This is the fetch-event callback.
    LoggerManager.logError("[BackgroundFetch] Event received: $taskId");
    setState(() {
      _events.insert(0, "$taskId@${timestamp.toString()}");
    });
    // Persist fetch events in SharedPreferences
    prefs.setString("fetch_events", jsonEncode(_events));

    if (taskId == "com.transistorsoft.kaouka.task") {
      // Perform an example HTTP request.
      postLocation("test", 1, 1);
    }
    // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }

  /// This event fires shortly before your task is about to timeout.  You must finish any outstanding work and call BackgroundFetch.finish(taskId).
  void _onBackgroundFetchTimeout(String taskId) {
    LoggerManager.logError("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MessageNotifier.instance.removeListener(getContactsNotif);
    onDisconnection(sharedData.getId);
    super.dispose();
  }

  FloatingActionButtonLocation floatingButtonPos =
      FloatingActionButtonLocation.endFloat;
  bool isWritingPost = false;
  @override
  Widget build(BuildContext context) {
    isToggled =
        Provider.of<PersistentVisibleProvider>(context).isVisibleChanged;
    imageUrl = Provider.of<PersistentImageProvider>(context, listen: false)
        .isImageChanged;
    imageScale =
        Provider.of<PersistentImageProvider>(context, listen: false).scale;
    imageOffset =
        Provider.of<PersistentImageProvider>(context, listen: false).offset;
    // PersistentModeProvider modeProvider =
    //     Provider.of<PersistentModeProvider>(context, listen: false);
    return Scaffold(
      body: !lostConnection
          ? Stack(children: [
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    if (index >= 2) {
                      _currentIndex = index + 1;
                    } else {
                      _currentIndex = index;
                    }
                  });
                },
                children: _pages,
              ),
              isMenuOpen
                  ? UserMenu(
                      toggleMenu: toggleMenu,
                    )
                  : Container()
            ])
          : const LostConnectionPage(),
      floatingActionButton: selector
          ? GestureDetector(
              onHorizontalDragEnd: onSwipe,
              onVerticalDragEnd: onVerticalSwipe,
              child: FloatingActionButton(
                onPressed: toggleMenu,
                child: Icon(isMenuOpen ? Icons.close : Icons.menu),
              ),
            )
          : Container(),
      floatingActionButtonLocation: floatingButtonPos,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
      bottomSheet: isWritingPost
          ? InputBar(
              onSubmitted: _submit,
              onChanged: (value) {},
              controller: _textEditingController,
              hintText: 'Send a request',
              maxLines: 1,
              maxLength: 200,
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(133, 0, 0, 0),
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [plainSurfaceBeginLight, plainSurfaceEndLight],
          // ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedFontSize: 12,
          showSelectedLabels: true,
          enableFeedback: true,
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              if (index == 2) {
                isWritingPost = !isWritingPost;
              } else if (index == 3 || index == 4) {
                _currentIndex = index - 1;
                _pageController.jumpToPage(_currentIndex);
              } else {
                _currentIndex = index;
                _pageController.jumpToPage(_currentIndex);
              }
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Accueil',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.device_unknown,
              ),
              label: 'surprise',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(
                      40 / 2), // Half of height for perfect circle
                ),
                child: const Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: BadgeIcon(
                iconData: Icons.message,
                notificationCount: notifCount,
              ),
              label: 'Contacts',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: isToggled ? toogleActiveColor : Colors.grey,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
