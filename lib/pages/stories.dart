import 'package:advstory/advstory.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/models/story_model.dart';
import 'package:eipoca/providers/story_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class Stories extends StatefulWidget {
  const Stories({super.key});

  @override
  State<Stories> createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  final Db _db = Db();

  @override
  void initState() {
    _db.getAllStories().listen((event) {
      List<StoryModel> stories = [];

      event.docs.forEach((element) {
        StoryModel s = StoryModel.fromMap(element.data());
        stories.add(s);
      });

      Provider.of<StoryProvider>(context, listen: false).updateStories(stories);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var stories = Provider.of<StoryProvider>(context).stories;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: stories.length,
      itemBuilder: (context, index) {
        return ListTile(
          // leading: ClipRRect(
          //   borderRadius: BorderRadius.circular(1000000),
          //   child: CachedNetworkImage(
          //     imageUrl: stories[index].pfpUrl.toDecodedBase64,
          //     height: 40,
          //     width: 40,
          //     fit: BoxFit.cover,
          //   ),
          // ),
          leading: AdvStory(
            storyCount: 1,
            storyBuilder: (storyIndex) => Story(
              contentCount: 1,
              contentBuilder: (contentIndex) => ImageContent(
                url: stories[index].url.toDecodedBase64,
              ),
            ),
            trayBuilder: (storyIndex) => AdvStoryTray(
              size: const Size(45, 45),
              url: stories[index].pfpUrl.toDecodedBase64,
            ),
          ),
        );
      },
    );
  }
}
