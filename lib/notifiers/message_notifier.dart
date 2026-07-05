import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageNotifier extends ChangeNotifier {
  MessageNotifier._internal();
  static final MessageNotifier _instance = MessageNotifier._internal();
  static MessageNotifier get instance => _instance;

  factory MessageNotifier() {
    return _instance;
  }

  int _messagenb = 0;
  int get messagenb => _messagenb;

  late CustomMessage _message;
  CustomMessage get message => _message;

  void addCustomMessage(CustomMessage customMessage) {
    _message = customMessage;
    _messagenb++;
    notifyListeners();
  }

  void clear() {
    _messagenb = 0;
    notifyListeners();
  }
}
