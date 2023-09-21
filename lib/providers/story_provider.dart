import 'package:eipoca/models/story_model.dart';
import 'package:flutter/material.dart';

class StoryProvider extends ChangeNotifier {
  List<StoryModel> _stories = [];
  List<StoryModel> get stories => _stories;

  void updateStories(List<StoryModel> data) {
    _stories = data;
    notifyListeners();
  }
}
