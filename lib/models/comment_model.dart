// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CommentModel {
  String comment;
  String commentedBy;
  int createdAt;
  String id;
  String postId;
  String serverId;

  CommentModel({
    required this.comment,
    required this.commentedBy,
    required this.createdAt,
    required this.id,
    required this.postId,
    required this.serverId,
  });

  CommentModel copyWith({
    String? comment,
    String? commentedBy,
    int? createdAt,
    String? id,
    String? postId,
    String? serverId,
  }) {
    return CommentModel(
      comment: comment ?? this.comment,
      commentedBy: commentedBy ?? this.commentedBy,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      postId: postId ?? this.postId,
      serverId: serverId ?? this.serverId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'comment': comment,
      'commentedBy': commentedBy,
      'createdAt': createdAt,
      'id': id,
      'postId': postId,
      'serverId': serverId,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      comment: map['comment'] as String,
      commentedBy: map['commentedBy'] as String,
      createdAt: map['createdAt'] as int,
      id: map['id'] as String,
      postId: map['postId'] as String,
      serverId: map['serverId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentModel.fromJson(String source) =>
      CommentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CommentModel(comment: $comment, commentedBy: $commentedBy, createdAt: $createdAt, id: $id, postId: $postId, serverId: $serverId)';
  }

  @override
  bool operator ==(covariant CommentModel other) {
    if (identical(this, other)) return true;

    return other.comment == comment &&
        other.commentedBy == commentedBy &&
        other.createdAt == createdAt &&
        other.id == id &&
        other.postId == postId &&
        other.serverId == serverId;
  }

  @override
  int get hashCode {
    return comment.hashCode ^
        commentedBy.hashCode ^
        createdAt.hashCode ^
        id.hashCode ^
        postId.hashCode ^
        serverId.hashCode;
  }
}
