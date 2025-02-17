import 'http_manager.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logging.dart';

class SharedData {
  SharedData._();
  static final SharedData _instance = SharedData._();
  factory SharedData() => _instance;

  SharedPreferences? _prefs;

  bool cleared = false;
  String id = "123";
  String name = "undefined";
  bool visible = true;
  bool payed = false;
  String imageUrl = "https://elaborium.site/proxy/stream/default/profile.jpg";
  double imageScale = 1.0;
  Offset imageOffset = const Offset(0, 0);
  bool requestedPermission = false;
  bool generalCondition = false;
  String socketId = "";
  bool notifScheduled = false;
  String notifDay = DateTime(2090).toString();
  String notifHour = DateTime(1987).toString();
  String notifToken = "";
  bool mode = false;
  bool configScheduled = false;
  List<String> logs = [];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
    dataChanged();
    LoggerManager.logInfo(
        'id: $id, name: $name, visible: $visible, payed: $payed, image: $imageUrl');
  }

  Future<void> reinit() async {
    init();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    id = _prefs!.getString('id') ?? "";
    name = _prefs!.getString('name') ?? "undefined";
    visible = _prefs!.getBool('visible') ?? true;
    payed = _prefs!.getBool('payed') ?? false;
    imageUrl = _prefs!.getString('imageUrl') ??
        "https://elaborium.site/proxy/stream/default/profile.jpg";
    imageScale = _prefs!.getDouble('imageScale') ?? 1.0;
    double offsetX = _prefs!.getDouble('imageOffsetX') ?? 0.0;
    double offsetY = _prefs!.getDouble('imageOffsetY') ?? 0.0;
    imageOffset = Offset(offsetX, offsetY);
    requestedPermission = _prefs!.getBool('requestedPermission') ?? false;
    generalCondition = _prefs!.getBool('generalCondition') ?? false;
    notifScheduled = _prefs!.getBool('notifScheduled') ?? false;
    notifDay = _prefs!.getString('notifDay') ?? DateTime(1987).toString();
    notifHour = _prefs!.getString('notifHour') ?? DateTime(1987).toString();
    notifToken = _prefs!.getString('notifToken') ?? "";
    mode = _prefs!.getBool('mode') ?? false;
    configScheduled = _prefs!.getBool('configScheduled') ?? false;

    // List<String> logs = _prefs!.getStringList('background_logs') ?? [];

    LoggerManager.logInfo(
        'id: $id, name: $name, visible: $visible, payed: $payed, image: $imageUrl');
  }

  Future<void> clear() async {
    await _prefs?.clear();
    id = "undefined";
    name = "undefined";
    visible = true;
    payed = false;
    imageUrl = "https://elaborium.site/proxy/stream/default/profile.jpg";
    imageScale = 0.0;
    imageOffset = const Offset(0, 0);
    requestedPermission = false;
    generalCondition = false;
    socketId = "";
    notifScheduled = false;
    notifDay = DateTime(2090).toString();
    notifHour = DateTime(1987).toString();
    notifToken = "";
    mode = false;
    configScheduled = false;
    cleared = true;
  }

  dataChanged() async {
    // await http.postInfos(id, name, imageUrl, imageScale, imageOffset.dx,
    //     imageOffset.dy, socketId, notifToken);
  }

  visibleChanged() async {
    await http.visible(id, visible.toString());
  }

  // Getter and Setter for 'id'
  String get getId => id;
  set setId(String value) {
    id = value;
    _prefs?.setString('id', value);
  }

  // Getter and Setter for 'name'
  String get getName => name;
  set setName(String value) {
    name = value.isEmpty ? "undefined" : value;
    _prefs?.setString('name', value);
    http.postName(id, name);
  }

  // Getter and Setter for 'visible'
  bool get getVisible => visible;
  set setVisible(bool value) {
    visible = value;
    _prefs?.setBool('visible', value);
    visibleChanged();
  }

  // Getter and Setter for 'payed'
  bool get getPayed => payed;
  set setPayed(bool value) {
    payed = value;
    _prefs?.setBool('payed', value);
    dataChanged();
  }

  // Getter and Setter for 'imageUrl'
  String get getImageUrl => imageUrl;
  set setImageUrl(String value) {
    http.postPP(id, value).then((value) => {
          if (value != "unset")
            {_prefs?.setString('imageUrl', value), imageUrl = value}
        });
  }

  // Getter and Setter for 'imageScale'
  double get getImageScale => imageScale;
  set setImageScale(double value) {
    imageScale = value;
    _prefs?.setDouble('imageScale', value);
    http.postPPSetting(id, imageScale, imageOffset.dx, imageOffset.dy);
  }

  // Getter and Setter for 'imageOffset'
  Offset get getImageOffset => imageOffset;
  set setImageOffset(Offset value) {
    imageOffset = value;
    _prefs?.setDouble('imageOffsetX', value.dx);
    _prefs?.setDouble('imageOffsetY', value.dy);
    http.postPPSetting(id, imageScale, imageOffset.dx, imageOffset.dy);
  }

  bool get getRequestedPermission => requestedPermission;
  set setRequestedPermission(bool value) {
    requestedPermission = value;
    _prefs?.setBool('requestedPermission', value);
  }

  bool get getGeneralCondition => generalCondition;
  set setGeneralCondition(bool value) {
    generalCondition = value;
    _prefs?.setBool('generalCondition', value);
  }

  set setSocketId(String value) {
    socketId = value;
  }

  set setNotifToken(String value) {
    notifToken = value;
    http.postNotifToken(id, notifToken);
  }

  bool get getNotifyScheduled => notifScheduled;
  set setNotifyScheduled(bool value) {
    notifScheduled = value;
    _prefs?.setBool('notifScheduled', value);
  }

  DateTime? get getNotifyDay => DateTime.tryParse(notifDay);
  set setNotifyDay(DateTime value) {
    notifDay = value.toString();
    _prefs!.setString('notifDay', value.toString());
  }

  DateTime? get getNotifyHour => DateTime.tryParse(notifHour);
  set setNotifyHour(DateTime value) {
    notifHour = value.toString();
    _prefs?.setString('notifHour', value.toString());
  }

  bool get getMode => mode;
  set setMode(bool value) {
    mode = value;
    _prefs?.setBool('mode', value);
  }

  bool get getConfigScheduled => configScheduled;
  set setConfigScheduled(bool value) {
    configScheduled = value;
    _prefs?.setBool('configScheduled', value);
  }

  List<String> get getLogs => logs;
  set setLog(String log) {
    logs.add(log);
    _prefs?.setStringList("logs", logs);
  }
}
