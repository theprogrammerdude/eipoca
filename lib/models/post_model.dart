// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class PostModel {
  int createdAt;
  String creator;
  int downvotes;
  String id;
  String post;
  String serverId;
  String type;
  String? url;
  int views;
  int votes;
  String? xid;
  List<dynamic> likes;

  PostModel({
    required this.createdAt,
    required this.creator,
    required this.downvotes,
    required this.id,
    required this.post,
    required this.serverId,
    required this.type,
    this.url,
    required this.views,
    required this.votes,
    this.xid,
    required this.likes,
  });

  PostModel copyWith({
    int? createdAt,
    String? creator,
    int? downvotes,
    String? id,
    String? post,
    String? serverId,
    String? type,
    String? url,
    int? views,
    int? votes,
    String? xid,
    List<dynamic>? likes,
  }) {
    return PostModel(
      createdAt: createdAt ?? this.createdAt,
      creator: creator ?? this.creator,
      downvotes: downvotes ?? this.downvotes,
      id: id ?? this.id,
      post: post ?? this.post,
      serverId: serverId ?? this.serverId,
      type: type ?? this.type,
      url: url ?? this.url,
      views: views ?? this.views,
      votes: votes ?? this.votes,
      xid: xid ?? this.xid,
      likes: likes ?? this.likes,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createdAt': createdAt,
      'creator': creator,
      'downvotes': downvotes,
      'id': id,
      'post': post,
      'serverId': serverId,
      'type': type,
      'url': url,
      'views': views,
      'votes': votes,
      'xid': xid,
      'likes': likes,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      createdAt: map['createdAt'] as int,
      creator: map['creator'] as String,
      downvotes: map['downvotes'] as int,
      id: map['id'] as String,
      post: map['post'] as String,
      serverId: map['serverId'] as String,
      type: map['type'] as String,
      url: map['url'] != null ? map['url'] as String : null,
      views: map['views'] as int,
      votes: map['votes'] as int,
      xid: map['xid'] != null ? map['xid'] as String : null,
      likes: List<dynamic>.from((map['likes'] as List<dynamic>)),
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PostModel(createdAt: $createdAt, creator: $creator, downvotes: $downvotes, id: $id, post: $post, serverId: $serverId, type: $type, url: $url, views: $views, votes: $votes, xid: $xid, likes: $likes)';
  }

  @override
  bool operator ==(covariant PostModel other) {
    if (identical(this, other)) return true;

    return other.createdAt == createdAt &&
        other.creator == creator &&
        other.downvotes == downvotes &&
        other.id == id &&
        other.post == post &&
        other.serverId == serverId &&
        other.type == type &&
        other.url == url &&
        other.views == views &&
        other.votes == votes &&
        other.xid == xid &&
        listEquals(other.likes, likes);
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        creator.hashCode ^
        downvotes.hashCode ^
        id.hashCode ^
        post.hashCode ^
        serverId.hashCode ^
        type.hashCode ^
        url.hashCode ^
        views.hashCode ^
        votes.hashCode ^
        xid.hashCode ^
        likes.hashCode;
  }
}
