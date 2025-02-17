import 'package:flutter/material.dart';
import '../shared_data.dart';

class PersistentModeProvider extends ChangeNotifier {
  late bool _isModeChanged;
  bool get isModeChanged => _isModeChanged;
  SharedData shared = SharedData();

  PersistentModeProvider() {
    _initFromSharedPreferences();
  }

  Future<void> _initFromSharedPreferences() async {
    SharedData shared = SharedData();
    _isModeChanged = shared.getMode;
    notifyListeners();
  }

  void setModeChanged(bool value) {
    _isModeChanged = value;
    shared.setMode = value;
    notifyListeners();
  }
}
