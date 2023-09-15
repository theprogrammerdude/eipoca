// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DmModel {
  int createdAt;
  String id;
  String msg;
  String senderUid;
  String receiverUid;
  String chatId;
  String type;
  String? url;
  String? xid;
  bool? edited;
  int? editedAt;

  DmModel({
    required this.createdAt,
    required this.id,
    required this.msg,
    required this.senderUid,
    required this.receiverUid,
    required this.chatId,
    required this.type,
    this.url,
    this.xid,
    this.edited,
    this.editedAt,
  });

  DmModel copyWith({
    int? createdAt,
    String? id,
    String? msg,
    String? senderUid,
    String? receiverUid,
    String? chatId,
    String? type,
    String? url,
    String? xid,
    bool? edited,
    int? editedAt,
  }) {
    return DmModel(
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      msg: msg ?? this.msg,
      senderUid: senderUid ?? this.senderUid,
      receiverUid: receiverUid ?? this.receiverUid,
      chatId: chatId ?? this.chatId,
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
      'receiverUid': receiverUid,
      'chatId': chatId,
      'type': type,
      'url': url,
      'xid': xid,
      'edited': edited,
      'editedAt': editedAt,
    };
  }

  factory DmModel.fromMap(Map<String, dynamic> map) {
    return DmModel(
      createdAt: map['createdAt'] as int,
      id: map['id'] as String,
      msg: map['msg'] as String,
      senderUid: map['senderUid'] as String,
      receiverUid: map['receiverUid'] as String,
      chatId: map['chatId'] as String,
      type: map['type'] as String,
      url: map['url'] != null ? map['url'] as String : null,
      xid: map['xid'] != null ? map['xid'] as String : null,
      edited: map['edited'] != null ? map['edited'] as bool : null,
      editedAt: map['editedAt'] != null ? map['editedAt'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DmModel.fromJson(String source) =>
      DmModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DmModel(createdAt: $createdAt, id: $id, msg: $msg, senderUid: $senderUid, receiverUid: $receiverUid, chatId: $chatId, type: $type, url: $url, xid: $xid, edited: $edited, editedAt: $editedAt)';
  }

  @override
  bool operator ==(covariant DmModel other) {
    if (identical(this, other)) return true;

    return other.createdAt == createdAt &&
        other.id == id &&
        other.msg == msg &&
        other.senderUid == senderUid &&
        other.receiverUid == receiverUid &&
        other.chatId == chatId &&
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
        receiverUid.hashCode ^
        chatId.hashCode ^
        type.hashCode ^
        url.hashCode ^
        xid.hashCode ^
        edited.hashCode ^
        editedAt.hashCode;
  }
}
