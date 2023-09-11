import 'package:eipoca/models/comment_model.dart';
import 'package:eipoca/models/post_model.dart';
import 'package:eipoca/models/chat_model.dart';
import 'package:eipoca/models/server_model.dart';
import 'package:eipoca/models/user_model.dart';
import 'package:flutter/material.dart';

class ServerProvider extends ChangeNotifier {
  List<ServerModel> _serversList = [];
  List<ServerModel> get serversList => _serversList;

  List<UserModel> _usersList = [];
  List<UserModel> get usersList => _usersList;

  Map<String, dynamic> _serverInfo = {};
  ServerModel get serverInfo => ServerModel.fromMap(_serverInfo);

  List<PostModel> _posts = [];
  List<PostModel> get posts => _posts;

  List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;

  List<ChatModel> _chats = [];
  List<ChatModel> get chats => _chats;

  void updateServerList(List<ServerModel> data) {
    _serversList = data;
    notifyListeners();
  }

  void updateUsersList(List<UserModel> data) {
    _usersList = data;
    notifyListeners();
  }

  void updateServerInfo(Map<String, dynamic> data) {
    _serverInfo = data;
    notifyListeners();
  }

  void updatePosts(List<PostModel> data) {
    _posts = data;
    notifyListeners();
  }

  void updateComments(List<CommentModel> data) {
    _comments = data;
    notifyListeners();
  }

  void updateChats(List<ChatModel> data) {
    _chats = data;
    notifyListeners();
  }
}
