import 'package:eipoca/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic> _user = {};
  UserModel get user => UserModel.fromMap(_user);

  void updateUser(Map<String, dynamic> d) {
    _user = d;
    notifyListeners();
  }
}
