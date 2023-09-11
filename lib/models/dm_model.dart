// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DmModel {
  int createdAt;
  String id;
  String msg;
  String senderUid;
  String chatId;
  String type;
  String? url;
  String? xid;

  DmModel({
    required this.createdAt,
    required this.id,
    required this.msg,
    required this.senderUid,
    required this.chatId,
    required this.type,
    this.url,
    this.xid,
  });

  DmModel copyWith({
    int? createdAt,
    String? id,
    String? msg,
    String? senderUid,
    String? chatId,
    String? type,
    String? url,
    String? xid,
  }) {
    return DmModel(
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      msg: msg ?? this.msg,
      senderUid: senderUid ?? this.senderUid,
      chatId: chatId ?? this.chatId,
      type: type ?? this.type,
      url: url ?? this.url,
      xid: xid ?? this.xid,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createdAt': createdAt,
      'id': id,
      'msg': msg,
      'senderUid': senderUid,
      'chatId': chatId,
      'type': type,
      'url': url,
      'xid': xid,
    };
  }

  factory DmModel.fromMap(Map<String, dynamic> map) {
    return DmModel(
      createdAt: map['createdAt'] as int,
      id: map['id'] as String,
      msg: map['msg'] as String,
      senderUid: map['senderUid'] as String,
      chatId: map['chatId'] as String,
      type: map['type'] as String,
      url: map['url'] != null ? map['url'] as String : null,
      xid: map['xid'] != null ? map['xid'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DmModel.fromJson(String source) =>
      DmModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DmModel(createdAt: $createdAt, id: $id, msg: $msg, senderUid: $senderUid, chatId: $chatId, type: $type, url: $url, xid: $xid)';
  }

  @override
  bool operator ==(covariant DmModel other) {
    if (identical(this, other)) return true;

    return other.createdAt == createdAt &&
        other.id == id &&
        other.msg == msg &&
        other.senderUid == senderUid &&
        other.chatId == chatId &&
        other.type == type &&
        other.url == url &&
        other.xid == xid;
  }

  @override
  int get hashCode {
    return createdAt.hashCode ^
        id.hashCode ^
        msg.hashCode ^
        senderUid.hashCode ^
        chatId.hashCode ^
        type.hashCode ^
        url.hashCode ^
        xid.hashCode;
  }
}
