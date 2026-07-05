import 'package:flutter/material.dart';
import '../models/person.dart';

class PeopleNotifier extends ChangeNotifier {
  List<ReqPerson> _people = [];

  List<ReqPerson> get people => _people;

  void setArrounds(List<ReqPerson> persons) {
    _people = persons;
    notifyListeners();
  }
}
