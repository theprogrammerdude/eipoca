import 'package:eipoca/methods/db.dart';
import 'package:eipoca/models/post_model.dart';
import 'package:eipoca/pages/create_post.dart';
import 'package:eipoca/pages/server_chat.dart';
import 'package:eipoca/providers/server_provider.dart';
import 'package:eipoca/widgets/post_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:xid/xid.dart';

class ServerFeed extends StatefulWidget {
  const ServerFeed({super.key, required this.id});

  final String id;

  @override
  State<ServerFeed> createState() => _ServerFeedState();
}

class _ServerFeedState extends State<ServerFeed> {
  final Db _db = Db();
  var xid = Xid();

  @override
  void initState() {
    _db.getServerPosts(widget.id).listen((event) {
      List<PostModel> posts = [];

      for (var element in event.docs) {
        PostModel p = PostModel.fromMap(element.data());
        posts.add(p);
      }

      Provider.of<ServerProvider>(context, listen: false).updatePosts(posts);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var posts = Provider.of<ServerProvider>(context).posts;

    return Scaffold(
      appBar: AppBar(
        title: 'Feed'.text.bold.make(),
        centerTitle: true,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'create_post',
            onPressed: () {
              Get.to(() => CreatePost(serverId: widget.id));
            },
            child: const Icon(Icons.create),
          ).pOnly(bottom: 10),
          FloatingActionButton(
            heroTag: 'chat',
            onPressed: () {
              Get.to(() => ServerChat(id: widget.id));
            },
            child: const Icon(Icons.chat_rounded),
          ),
        ],
      ),
      body: posts.isNotEmpty
          ? GridView.custom(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverQuiltedGridDelegate(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                repeatPattern: QuiltedGridRepeatPattern.inverted,
                pattern: const [
                  QuiltedGridTile(2, 2),
                  QuiltedGridTile(1, 1),
                  QuiltedGridTile(1, 1),
                  QuiltedGridTile(1, 2),
                ],
              ),
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) {
                  var post = posts[index];

                  return PostWidget(
                    post: post,
                  );
                },
                childCount: posts.length,
              ),
            ).p12()
          : Center(
              child:
                  'No Posts in this server yet'.text.headline6(context).make(),
            ),
    );
  }
}
