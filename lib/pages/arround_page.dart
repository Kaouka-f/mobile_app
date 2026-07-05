import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:kaouka/http/routes/get/get_arrounds.dart';
import 'package:kaouka/http/routes/post/post_location.dart';
import 'package:permission_handler/permission_handler.dart';

import '../notifiers/message_notifier.dart';
import '../core/shared_data.dart';
import '../utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../components/req_person_list.dart';
import '../models/person.dart';

class ArroundPage extends StatefulWidget {
  const ArroundPage({super.key});

  @override
  State<ArroundPage> createState() => _ArroundPageState();
}

class _ArroundPageState extends State<ArroundPage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  bool hasTriggerUp = false;
  late Position position;
  SharedData sharedData = SharedData();
  final MessageNotifier newMessageNotifier = MessageNotifier();
  List<ReqPerson> peoples = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _startLocationTimer();
      _stopPostLocationTimer();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      _stopLocationTimer();
      if (state == AppLifecycleState.paused) _startPostLocationTimer();
    }
  }

  Future<void> getArround() async {
    // await _disposeCompleter.future;
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      String id = sharedData.getId;
      // print("shared logs =  ${sharedData.logs}");
      List<ReqPerson> peoples =
          await getArrounds(id, position.longitude, position.latitude);
      setState(() {
        this.peoples = peoples;
      });
      peoples.sort((a, b) => a.dist.compareTo(b.dist));
      // ignore: use_build_context_synchronously
      // Provider.of<PeopleNotifier>(context, listen: false)
      //     .setArrounds(peoples);
    } catch (e) {
      if (kDebugMode) print('arround page get arround error: $e');
    }
  }

  // HACK: make get location faster
  Timer? _locationTimer;
  void _startLocationTimer() {
    _locationTimer =
        Timer.periodic(const Duration(seconds: 5), _onLocationTimerTick);
  }

  void _stopLocationTimer() {
    _locationTimer?.cancel();
  }

  void _onLocationTimerTick(Timer timer) async {
    if (mounted) {
      getLocation();
    }
  }

  // post location on foreground
  Timer? _postLocationTimer;
  void _startPostLocationTimer() {
    _postLocationTimer =
        Timer.periodic(const Duration(seconds: 5), _onPostLocationTimerTick);
  }

  void _stopPostLocationTimer() {
    _postLocationTimer?.cancel();
  }

  void _onPostLocationTimerTick(Timer timer) async {
    if (mounted) {
      postLocation(sharedData.id, position.longitude, position.latitude);
    }
  }

  Future<void> getLocation() async {
    Position? pos = await getCurrentLocation();
    if (pos != null) {
      position = pos;
    } else {
      String geolocMsg =
          "vous avez refuser d'autoriser la geolocalisation, l'application est inutile sans, nous vous conseillons de déinstaller l'application";
      // ignore: use_build_context_synchronously
      showPopUp(context, "localisation", geolocMsg, () => (openAppSettings()));
      _locationTimer?.cancel();
      _postLocationTimer?.cancel();
    }
  }

  initLocation() async {
    await getLocation();
    await getArround();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startLocationTimer();
    initLocation();
  }

  final Completer<void> _disposeCompleter = Completer<void>();
  @override
  void dispose() {
    _locationTimer?.cancel();
    _disposeCompleter.complete();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getArround,
      key: _refreshIndicatorKey,
      color: Colors.white,
      child: SingleChildScrollView(
        controller: _scrollController,
        primary: false,
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            children: [
              hasTriggerUp
                  ? const RefreshProgressIndicator(
                      backgroundColor: Colors.black,
                      color: Colors.white,
                    )
                  : Container(),
              ReqPersonList(
                personList: peoples,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
