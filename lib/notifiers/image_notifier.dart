import 'package:flutter/material.dart';
import '../shared_data.dart';

class PersistentImageProvider extends ChangeNotifier {
  String _isImageChanged = "";
  String get isImageChanged => _isImageChanged;
  double _scale = 1;
  double get scale => _scale;
  Offset _offset = const Offset(0, 0);
  Offset get offset => _offset;
  SharedData shared = SharedData();

  PersistentImageProvider() {
    _initFromSharedPreferences();
  }

  Future<void> _initFromSharedPreferences() async {
    _isImageChanged = shared.getImageUrl;
    _scale = shared.getImageScale;
    _offset = shared.getImageOffset;
    notifyListeners();
  }

  void setImageChanged(String url, double scale, Offset offset) {
    _isImageChanged = url;
    shared.setImageUrl = url;
    _scale = scale;
    shared.setImageScale = scale;
    _offset = offset;
    shared.setImageOffset = offset;
    notifyListeners();
  }
}
