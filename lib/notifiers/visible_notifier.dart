import 'package:flutter/material.dart';
import '../shared_data.dart';

class PersistentVisibleProvider extends ChangeNotifier {
  late bool _isVisibleChanged;
  bool get isVisibleChanged => _isVisibleChanged;
  SharedData shared = SharedData();

  PersistentVisibleProvider() {
    _initFromSharedPreferences();
  }

  Future<void> _initFromSharedPreferences() async {
    SharedData shared = SharedData();
    _isVisibleChanged = shared.getVisible;
    notifyListeners();
  }

  void setVisibleChanged(bool value) {
    _isVisibleChanged = value;
    shared.setVisible = value;
    notifyListeners();
  }
}
