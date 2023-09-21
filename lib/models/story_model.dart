// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class StoryModel {
  int createdAt;
  String id;
  int ttl;
  String uid;
  String url;
  String username;
  String firstname;
  String lastname;
  String pfpUrl;

  StoryModel({
    required this.createdAt,
    required this.id,
    required this.ttl,
    required this.uid,
    required this.url,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.pfpUrl,
  });

  StoryModel copyWith({
    int? createdAt,
    String? id,
    int? ttl,
    String? uid,
    String? url,
    String? username,
    String? firstname,
    String? lastname,
    String? pfpUrl,
  }) {
    return StoryModel(
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      ttl: ttl ?? this.ttl,
      uid: uid ?? this.uid,
      url: url ?? this.url,
      username: username ?? this.username,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      pfpUrl: pfpUrl ?? this.pfpUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createdAt': createdAt,
      'id': id,
      'ttl': ttl,
      'uid': uid,
      'url': url,
      'username': username,
      'firstname': firstname,
      'lastname': lastname,
      'pfpUrl': pfpUrl,
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      createdAt: map['createdAt'] as int,
      id: map['id'] as String,
      ttl: map['ttl'] as int,
      uid: map['uid'] as String,
      url: map['url'] as String,
      username: map['username'] as String,
      firstname: map['firstname'] as String,
      lastname: map['lastname'] as String,
      pfpUrl: map['pfpUrl'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory StoryModel.fromJson(String source) =>
      StoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'StoryModel(createdAt: $createdAt, id: $id, ttl: $ttl, uid: $uid, url: $url, username: $username, firstname: $firstname, lastname: $lastname, pfpUrl: $pfpUrl)';
  }

  @override
  bool operator ==(covariant StoryModel other) {
    if (identical(this, other)) return true;

    return other.createdAt == createdAt &&
        other.id == id &&
        other.ttl == ttl &&
        other.uid == uid &&
        other.url == url &&
        other.username == username &&
        other.firstname == firstname &&
        other.lastname == lastname &&
        other.pfpUrl == pfpUrl;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        id.hashCode ^
        ttl.hashCode ^
        uid.hashCode ^
        url.hashCode ^
        username.hashCode ^
        firstname.hashCode ^
        lastname.hashCode ^
        pfpUrl.hashCode;
  }
}
