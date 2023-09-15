import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:xid/xid.dart';

class Upload {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String> uploadImg(String uid, File file) async {
    Reference ref = _firebaseStorage.ref().child('$uid/pfp');
    UploadTask task = ref.putFile(file);

    String url = await (await task).ref.getDownloadURL();

    return url;
  }

  Future<Map<String, String>> sendImgToServerChat(
      String serverId, File file) async {
    var xid = Xid();

    Reference ref = _firebaseStorage.ref().child('$serverId/${xid.toString()}');
    UploadTask task = ref.putFile(file);

    String url = await (await task).ref.getDownloadURL();

    return {
      'url': url,
      'xid': xid.toString(),
    };
  }

  Future<Map<String, String>> sendImgToChat(String chatId, File file) async {
    var xid = Xid();

    Reference ref = _firebaseStorage.ref().child('$chatId/${xid.toString()}');
    UploadTask task = ref.putFile(file);

    String url = await (await task).ref.getDownloadURL();

    return {
      'url': url,
      'xid': xid.toString(),
    };
  }

  Future<void> deleteImgFromServerChat(String serverId, String xid) {
    Reference ref = _firebaseStorage.ref().child('$serverId/${xid.toString()}');
    return ref.delete();
  }

  Future<void> deleteImgFromChat(String chatId, String xid) {
    Reference ref = _firebaseStorage.ref().child('$chatId/${xid.toString()}');
    return ref.delete();
  }

  Future<String> uploadServerPhoto(String id, File file) async {
    Reference ref = _firebaseStorage.ref().child('$id/serverPhoto');
    UploadTask task = ref.putFile(file);

    String url = await (await task).ref.getDownloadURL();

    return url;
  }

  Future<Map<String, String>> uploadImgToPost(
    Map<String, dynamic> data,
    File file,
  ) async {
    var xid = Xid();

    Reference ref = _firebaseStorage
        .ref()
        .child('${data['serverId']}/${data['[postId]']}/${xid.toString()}');
    UploadTask task = ref.putFile(file);

    String url = await (await task).ref.getDownloadURL();

    return {
      'url': url,
      'xid': xid.toString(),
    };
  }
}
