import 'package:firebase_messaging/firebase_messaging.dart';

class Messaging {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> get generateFCMToken => _firebaseMessaging.getToken();

  void get requestPermission => _firebaseMessaging.requestPermission();
}
