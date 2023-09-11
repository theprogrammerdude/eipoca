import 'package:eipoca/models/dm_model.dart';
import 'package:flutter/material.dart';

class DmProvider extends ChangeNotifier {
  List<DmModel> _chats = [];
  List<DmModel> get chats => _chats;

  void updateChats(List<DmModel> data) {
    _chats = data;
    notifyListeners();
  }
}
