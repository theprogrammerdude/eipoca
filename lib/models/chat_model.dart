// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ChatModel {
  int createdAt;
  String id;
  String msg;
  String senderUid;
  String serverId;
  String type;
  String? url;
  String? xid;
  bool? edited;
  int? editedAt;

  ChatModel({
    required this.createdAt,
    required this.id,
    required this.msg,
    required this.senderUid,
    required this.serverId,
    required this.type,
    this.url,
    this.xid,
    this.edited,
    this.editedAt,
  });

  ChatModel copyWith({
    int? createdAt,
    String? id,
    String? msg,
    String? senderUid,
    String? serverId,
    String? type,
    String? url,
    String? xid,
    bool? edited,
    int? editedAt,
  }) {
    return ChatModel(
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      msg: msg ?? this.msg,
      senderUid: senderUid ?? this.senderUid,
      serverId: serverId ?? this.serverId,
      type: type ?? this.type,
      url: url ?? this.url,
      xid: xid ?? this.xid,
      edited: edited ?? this.edited,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createdAt': createdAt,
      'id': id,
      'msg': msg,
      'senderUid': senderUid,
      'serverId': serverId,
      'type': type,
      'url': url,
      'xid': xid,
      'edited': edited,
      'editedAt': editedAt,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      createdAt: map['createdAt'] as int,
      id: map['id'] as String,
      msg: map['msg'] as String,
      senderUid: map['senderUid'] as String,
      serverId: map['serverId'] as String,
      type: map['type'] as String,
      url: map['url'] != null ? map['url'] as String : null,
      xid: map['xid'] != null ? map['xid'] as String : null,
      edited: map['edited'] != null ? map['edited'] as bool : null,
      editedAt: map['editedAt'] != null ? map['editedAt'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) =>
      ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatModel(createdAt: $createdAt, id: $id, msg: $msg, senderUid: $senderUid, serverId: $serverId, type: $type, url: $url, xid: $xid, edited: $edited, editedAt: $editedAt)';
  }

  @override
  bool operator ==(covariant ChatModel other) {
    if (identical(this, other)) return true;

    return other.createdAt == createdAt &&
        other.id == id &&
        other.msg == msg &&
        other.senderUid == senderUid &&
        other.serverId == serverId &&
        other.type == type &&
        other.url == url &&
        other.xid == xid &&
        other.edited == edited &&
        other.editedAt == editedAt;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        id.hashCode ^
        msg.hashCode ^
        senderUid.hashCode ^
        serverId.hashCode ^
        type.hashCode ^
        url.hashCode ^
        xid.hashCode ^
        edited.hashCode ^
        editedAt.hashCode;
  }
}
