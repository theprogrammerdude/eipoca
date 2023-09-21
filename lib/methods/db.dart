import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

class Db {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<void> createUserInDb(Map<String, dynamic> data) async {
    return await _db.doc('users/${data['uid']}').set({
      ...data,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) {
    return _db.doc('users/$uid').snapshots();
  }

  Future<Map<String, dynamic>> extractEmailFromUsername(String username) async {
    QuerySnapshot<Map<String, dynamic>> d = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    try {
      return d.docs.first.data();
    } catch (e) {
      // Bad state: No element
      return {};
    }
  }

  Future<bool> checkIfServerTagExists(String tag) async {
    QuerySnapshot<Map<String, dynamic>> d =
        await _db.collection('servers').where('tag', isEqualTo: tag).get();

    try {
      return d.docs.first.exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIfUserChatExists(String uid) async {
    QuerySnapshot<Map<String, dynamic>> d =
        await _db.collection('chats').where('0', isEqualTo: uid).get();

    try {
      return d.docs.first.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> createServer(Map<String, dynamic> data) async {
    Map<String, dynamic> d = {
      ...data,
      'id': _uuid.v4().toEncodedBase64,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };

    return await _db.doc('servers/${d['id']}').set(d);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getServersList(String uid) {
    return _db
        .collection('servers')
        .where('participants', arrayContains: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> searchPeople(String s) {
    return _db
        .collection('users')
        .orderBy('username', descending: false)
        .startAt([s])
        .endAt(['$s\uf8ff'])
        .limit(15)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getServerInfo(String id) {
    return _db.doc('servers/$id').snapshots();
  }

  Future<void> sendMessageToServer(Map<String, dynamic> data) {
    Map<String, dynamic> d = {
      ...data,
      'id': _uuid.v4().toEncodedBase64,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };

    return _db
        .doc('servers/${d['serverId']}')
        .collection('chats')
        .doc(d['id'])
        .set(d);
  }

  Future<void> sendDM(Map<String, dynamic> data) {
    Map<String, dynamic> d = {
      ...data,
      'id': _uuid.v4().toEncodedBase64,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };

    _db.doc('chats/${d['chatId']}').update({
      'lastMsg': d['msg'],
      'lastMsgType': d['type'],
      'lastMsgCreatedAt': DateTime.now().millisecondsSinceEpoch,
    });

    return _db
        .doc('chats/${d['chatId']}')
        .collection('msgs')
        .doc(d['id'])
        .set(d);
  }

  Future<void> addParticipantsInChat(Map<String, dynamic> data) async {
    _db.doc('users/${data['participants'][0]}').update({
      'chats': FieldValue.arrayUnion([
        data['chatId'],
      ])
    });

    _db.doc('users/${data['participants'][1]}').update({
      'chats': FieldValue.arrayUnion([
        data['chatId'],
      ])
    });

    return _db.doc('chats/${data['chatId']}').set({
      'chatId': data['chatId'],
      '0': data['participants'][0],
      '1': data['participants'][1],
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<String> getChatId(String uid) async {
    QuerySnapshot<Map<String, dynamic>> d =
        await _db.collection('chats').where('0', isEqualTo: uid).get();

    Map<String, dynamic> s = d.docs.first.data();
    return s['chatId'];
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getChatsDetails(
    String chatId,
  ) {
    return _db.doc('chats/$chatId').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChats(
    String chatId,
  ) {
    return _db
        .doc('chats/$chatId')
        .collection('msgs')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getServerChats(String id) {
    return _db
        .doc('servers/$id')
        .collection('chats')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getDms(String id) {
    return _db
        .collection('chats')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }

  Future<void> deleteChat(String serverId, String id) {
    return _db.doc('servers/$serverId').collection('chats').doc(id).delete();
  }

  Future<void> deleteDM(String chatId, String id) {
    return _db.doc('chats/$chatId').collection('msgs').doc(id).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> searchServers(String s) {
    return _db
        .collection('servers')
        .orderBy('tag', descending: false)
        .startAt([s])
        .endAt(['$s\uf8ff'])
        .limit(15)
        .snapshots();
  }

  updatePfp(String uid, String encryptedUrl) {
    return _db.doc('users/$uid').update({
      'pfpUrl': encryptedUrl,
    });
  }

  updatePaswordInDb(String uid, String encryptedPassword) {
    return _db.doc('users/$uid').update({
      'password': encryptedPassword,
    });
  }

  updateServerPhoto(String id, String encryptedUrl) {
    return _db.doc('servers/$id').update({
      'serverPhotoURL': encryptedUrl,
    });
  }

  Future<void> deleteUserData(String uid) {
    return _db.doc('users/$uid').delete();
  }

  addPostToServer(Map<String, dynamic> data) {
    return _db
        .doc('servers/${data['serverId']}')
        .collection('posts')
        .doc(data['id'])
        .set(
      {
        ...data,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'views': FieldValue.increment(1)
      },
      SetOptions(merge: true),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getServerPosts(String serverId) {
    return _db
        .doc('servers/$serverId')
        .collection('posts')
        .limit(50)
        .snapshots();
  }

  Future<void> addCommentToPost(Map<String, dynamic> data) async {
    return await _db
        .doc('servers/${data['serverId']}')
        .collection('posts')
        .doc(data['postId'])
        .collection('comments')
        .doc(data['id'])
        .set({
      ...data,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPostComments(
    Map<String, dynamic> data,
  ) {
    return _db
        .doc('servers/${data['serverId']}')
        .collection('posts')
        .doc(data['postId'])
        .collection('comments')
        .snapshots();
  }

  Future<void> joinServer(
    String id,
    String uid,
  ) async {
    return await _db.doc('servers/$id').update({
      'participants': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> likePost(Map<String, dynamic> data) async {
    return _db
        .doc('servers/${data['serverId']}')
        .collection('posts')
        .doc(data['postId'])
        .update({
      'likes': FieldValue.arrayUnion([data['uid']]),
    });
  }

  Future<void> removeLike(Map<String, dynamic> data) async {
    return _db
        .doc('servers/${data['serverId']}')
        .collection('posts')
        .doc(data['postId'])
        .update({
      'likes': FieldValue.arrayRemove([data['uid']]),
    });
  }

  Future<void> blockUser(String uid, String blockedUserId) async {
    String id = _uuid.v4().toEncodedBase64;

    return _db.doc('users/$uid').collection('blocklist').doc(id).set({
      'blockedUserId': blockedUserId,
      'blockedAt': DateTime.now().millisecondsSinceEpoch,
      'id': id,
    });
  }

  Future<void> deleteComment(Map<String, dynamic> data) async {
    return _db
        .doc('servers/${data['serverId']}')
        .collection('posts')
        .doc(data['postId'])
        .collection('comments')
        .doc(data['id'])
        .delete();
  }

  Future<void> changeServerName(Map<String, dynamic> data) async {
    return await _db.doc('servers/${data['id']}').update({
      'name': data['name'],
    });
  }

  Future<void> changeServerBio(Map<String, dynamic> data) async {
    return await _db.doc('servers/${data['id']}').update({
      'bio': data['bio'],
    });
  }

  Future<void> editMessage(Map<String, dynamic> data) async {
    _db.doc('chats/${data['chatId']}').update({
      'lastMsg': data['msg'],
      'edited': true,
      'lastMsgEditedAt': DateTime.now().millisecondsSinceEpoch,
    });

    return await _db
        .doc('chats/${data['chatId']}')
        .collection('msgs')
        .doc(data['id'])
        .update({
      'msg': data['msg'],
      'edited': true,
      'editedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> editServerMessage(Map<String, dynamic> data) async {
    return await _db
        .doc('servers/${data['serverId']}')
        .collection('chats')
        .doc(data['id'])
        .update({
      'msg': data['msg'],
      'edited': true,
      'editedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> addStory(Map<String, dynamic> data) async {
    return await _db.doc('stories/${data['id']}').set({
      ...data,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllStories() {
    return _db.collection('stories').snapshots();
  }
}
