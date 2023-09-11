// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class UserModel {
  String? bio;
  int createdAt;
  String dob;
  String email;
  bool emailVerified;
  String fcmToken;
  String firstname;
  String lastname;
  String password;
  bool permanentBan;
  String? pfpUrl;
  String uid;
  String username;
  List<dynamic> chats;

  UserModel({
    this.bio,
    required this.createdAt,
    required this.dob,
    required this.email,
    required this.emailVerified,
    required this.fcmToken,
    required this.firstname,
    required this.lastname,
    required this.password,
    required this.permanentBan,
    this.pfpUrl,
    required this.uid,
    required this.username,
    required this.chats,
  });

  UserModel copyWith({
    String? bio,
    int? createdAt,
    String? dob,
    String? email,
    bool? emailVerified,
    String? fcmToken,
    String? firstname,
    String? lastname,
    String? password,
    bool? permanentBan,
    String? pfpUrl,
    String? uid,
    String? username,
    List<dynamic>? chats,
  }) {
    return UserModel(
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      dob: dob ?? this.dob,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      fcmToken: fcmToken ?? this.fcmToken,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      password: password ?? this.password,
      permanentBan: permanentBan ?? this.permanentBan,
      pfpUrl: pfpUrl ?? this.pfpUrl,
      uid: uid ?? this.uid,
      username: username ?? this.username,
      chats: chats ?? this.chats,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bio': bio,
      'createdAt': createdAt,
      'dob': dob,
      'email': email,
      'emailVerified': emailVerified,
      'fcmToken': fcmToken,
      'firstname': firstname,
      'lastname': lastname,
      'password': password,
      'permanentBan': permanentBan,
      'pfpUrl': pfpUrl,
      'uid': uid,
      'username': username,
      'chats': chats,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      bio: map['bio'] != null ? map['bio'] as String : null,
      createdAt: map['createdAt'] as int,
      dob: map['dob'] as String,
      email: map['email'] as String,
      emailVerified: map['emailVerified'] as bool,
      fcmToken: map['fcmToken'] as String,
      firstname: map['firstname'] as String,
      lastname: map['lastname'] as String,
      password: map['password'] as String,
      permanentBan: map['permanentBan'] as bool,
      pfpUrl: map['pfpUrl'] != null ? map['pfpUrl'] as String : null,
      uid: map['uid'] as String,
      username: map['username'] as String,
      chats: List<dynamic>.from((map['chats'] as List<dynamic>)),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(bio: $bio, createdAt: $createdAt, dob: $dob, email: $email, emailVerified: $emailVerified, fcmToken: $fcmToken, firstname: $firstname, lastname: $lastname, password: $password, permanentBan: $permanentBan, pfpUrl: $pfpUrl, uid: $uid, username: $username, chats: $chats)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.bio == bio &&
        other.createdAt == createdAt &&
        other.dob == dob &&
        other.email == email &&
        other.emailVerified == emailVerified &&
        other.fcmToken == fcmToken &&
        other.firstname == firstname &&
        other.lastname == lastname &&
        other.password == password &&
        other.permanentBan == permanentBan &&
        other.pfpUrl == pfpUrl &&
        other.uid == uid &&
        other.username == username &&
        listEquals(other.chats, chats);
  }

  @override
  int get hashCode {
    return bio.hashCode ^
        createdAt.hashCode ^
        dob.hashCode ^
        email.hashCode ^
        emailVerified.hashCode ^
        fcmToken.hashCode ^
        firstname.hashCode ^
        lastname.hashCode ^
        password.hashCode ^
        permanentBan.hashCode ^
        pfpUrl.hashCode ^
        uid.hashCode ^
        username.hashCode ^
        chats.hashCode;
  }
}
