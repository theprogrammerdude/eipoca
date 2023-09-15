import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/models/comment_model.dart';
import 'package:eipoca/models/post_model.dart';
import 'package:eipoca/models/user_model.dart';
import 'package:eipoca/modules/cipher.dart';
import 'package:eipoca/providers/server_provider.dart';
import 'package:eipoca/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:xid/xid.dart';

class PostWidget extends StatefulWidget {
  const PostWidget({
    super.key,
    required this.post,
  });

  final PostModel post;

  @override
  State<PostWidget> createState() => PostWidgetState();
}

class PostWidgetState extends State<PostWidget> {
  final Db _db = Db();
  final Cipher _cipher = Cipher();
  final Local _local = Local();
  var xid = Xid();

  final TextEditingController _comment = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  commentSheet() {
    Map<String, dynamic> d = {
      'serverId': widget.post.serverId,
      'postId': widget.post.id,
    };

    _db.getPostComments(d).listen((event) {
      List<CommentModel> comments = [];

      for (var element in event.docs) {
        CommentModel c = CommentModel.fromMap(element.data());
        comments.add(c);
      }

      Provider.of<ServerProvider>(context, listen: false)
          .updateComments(comments);
    });

    showModalBottomSheet(
      context: context,
      builder: (context) {
        var comments = Provider.of<ServerProvider>(context).comments;

        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              'Comments'.text.bold.size(16).make().pOnly(bottom: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return StreamBuilder(
                    stream: _db.getUserData(comments[index].commentedBy),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasData) {
                        var user = UserModel.fromMap(
                            snapshot.data!.data() as Map<String, dynamic>);

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                user.username.text.bold.make().pOnly(right: 5),
                                _cipher
                                    .decryptData(comments[index].comment)
                                    .text
                                    .make(),
                              ],
                            ),
                            _local.getUid == widget.post.creator
                                ? IconButton(
                                    onPressed: () =>
                                        deleteComment(comments[index]),
                                    icon: const Icon(Icons.delete),
                                  )
                                : const SizedBox(width: 0),
                          ],
                        );
                      }

                      return const SizedBox(height: 0);
                    },
                  ).pOnly(bottom: 5).p4();
                },
              ).pOnly(bottom: 8),
              Card(
                color: Vx.gray200,
                child: Form(
                  key: _formkey,
                  child: CustomInput(
                    label: 'Your comment',
                    prefixIcon: const Icon(Icons.comment),
                    isObscure: false,
                    suffixIcon: IconButton(
                      onPressed: () => addComment(),
                      icon: const Icon(Icons.send),
                    ),
                    controller: _comment,
                  ),
                ),
              ),
            ],
          ).wPCT(context: context, widthPCT: 100).p12(),
        );
      },
    );
  }

  addComment() {
    if (_formkey.currentState!.validate()) {
      Map<String, dynamic> data = {
        'comment': _cipher.encryptData(_comment.text.trim()),
        'id': xid.toString(),
        'commentedBy': _local.getUid,
        'serverId': widget.post.serverId,
        'postId': widget.post.id,
      };

      _db.addCommentToPost(data).then((value) {
        _comment.clear();
      });
    }
  }

  deleteComment(CommentModel c) {
    Map<String, dynamic> data = {
      'id': c.id,
      'postId': c.postId,
      'serverId': c.serverId,
    };

    _db.deleteComment(data);
  }

  // like() {
  //   Map<String, dynamic> data = {
  //     'postId': widget.post.id,
  //     'serverId': widget.post.serverId,
  //     'uid': _local.getUid,
  //   };

  // widget.isLiked ? _db.removeLike(data) : _db.likePost(data);
  // }

  postDialog() {
    NDialog(
      title: const Text(''),
      content: widget.post.type == 'img'
          ? CachedNetworkImage(
              imageUrl: widget.post.url.toString().toDecodedBase64,
              fit: BoxFit.cover,
              height: 300,
              width: 300,
            ).cornerRadius(8)
          : Container(
              child: _cipher
                  .decryptData(widget.post.post)
                  .text
                  .bold
                  .headline3(context)
                  .wrapWords(true)
                  .make()
                  .h(300)
                  .w(300)
                  .p8()
                  .cornerRadius(8),
            ),
      actions: [
        TextButton.icon(
          onPressed: () => commentSheet(),
          icon: const Icon(Icons.comment),
          label: const Text('Comments'),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.save_as_rounded),
          label: const Text('Save'),
        ),
      ],
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => postDialog(),
      child: widget.post.type == 'img'
          ? CachedNetworkImage(
              imageUrl: widget.post.url.toString().toDecodedBase64,
              fit: BoxFit.cover,
            ).cornerRadius(8)
          : Container(
              child: _cipher
                  .decryptData(widget.post.post)
                  .text
                  .bold
                  .headline3(context)
                  .wrapWords(true)
                  .make()
                  .p8()
                  .backgroundColor(Vx.gray200)
                  .cornerRadius(8),
            ),
    );
  }
}
