import 'package:localstore/localstore.dart';

class LocalStorage {
  final db = Localstore.instance;

  Future<dynamic> addChatToLocal(Map<String, dynamic> data) async {
    return db.collection('chats').doc(data['chatId']).set({
      ...data,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> getChat(String chatId) async {
    return await db.collection('chats').doc(chatId).get();
  }

  Future<Map<String, dynamic>?> deleteChat(String chatId) async {
    return await db.collection('chats').doc(chatId).delete();
  }
}
