// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class ServerModel {
  int createdAt;
  String createdBy;
  String id;
  String name;
  String? bio;
  String? serverPhotoURL;
  String tag;
  int totalMembers;
  List<dynamic> participants;

  ServerModel({
    required this.createdAt,
    required this.createdBy,
    required this.id,
    required this.name,
    this.bio,
    this.serverPhotoURL,
    required this.tag,
    required this.totalMembers,
    required this.participants,
  });

  ServerModel copyWith({
    int? createdAt,
    String? createdBy,
    String? id,
    String? name,
    String? bio,
    String? serverPhotoURL,
    String? tag,
    int? totalMembers,
    List<dynamic>? participants,
  }) {
    return ServerModel(
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      serverPhotoURL: serverPhotoURL ?? this.serverPhotoURL,
      tag: tag ?? this.tag,
      totalMembers: totalMembers ?? this.totalMembers,
      participants: participants ?? this.participants,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createdAt': createdAt,
      'createdBy': createdBy,
      'id': id,
      'name': name,
      'bio': bio,
      'serverPhotoURL': serverPhotoURL,
      'tag': tag,
      'totalMembers': totalMembers,
      'participants': participants,
    };
  }

  factory ServerModel.fromMap(Map<String, dynamic> map) {
    return ServerModel(
      createdAt: map['createdAt'] as int,
      createdBy: map['createdBy'] as String,
      id: map['id'] as String,
      name: map['name'] as String,
      bio: map['bio'] != null ? map['bio'] as String : null,
      serverPhotoURL: map['serverPhotoURL'] != null
          ? map['serverPhotoURL'] as String
          : null,
      tag: map['tag'] as String,
      totalMembers: map['totalMembers'] as int,
      participants: List<dynamic>.from((map['participants'] as List<dynamic>)),
    );
  }

  String toJson() => json.encode(toMap());

  factory ServerModel.fromJson(String source) =>
      ServerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ServerModel(createdAt: $createdAt, createdBy: $createdBy, id: $id, name: $name, bio: $bio, serverPhotoURL: $serverPhotoURL, tag: $tag, totalMembers: $totalMembers, participants: $participants)';
  }

  @override
  bool operator ==(covariant ServerModel other) {
    if (identical(this, other)) return true;

    return other.createdAt == createdAt &&
        other.createdBy == createdBy &&
        other.id == id &&
        other.name == name &&
        other.bio == bio &&
        other.serverPhotoURL == serverPhotoURL &&
        other.tag == tag &&
        other.totalMembers == totalMembers &&
        listEquals(other.participants, participants);
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        createdBy.hashCode ^
        id.hashCode ^
        name.hashCode ^
        bio.hashCode ^
        serverPhotoURL.hashCode ^
        tag.hashCode ^
        totalMembers.hashCode ^
        participants.hashCode;
  }
}
