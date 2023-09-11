import 'package:cached_network_image/cached_network_image.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/models/user_model.dart';
import 'package:eipoca/modules/cipher.dart';
import 'package:eipoca/pages/chat.dart';
import 'package:eipoca/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final Db _db = Db();
  final Cipher _cipher = Cipher();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context).user;

    return user.chats.isNotEmpty
        ? ListView.builder(
            itemCount: user.chats.length,
            itemBuilder: (context, index) {
              return StreamBuilder(
                stream: _db.getChatsDetails(user.chats[index]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;

                    return StreamBuilder(
                      stream: _db.getUserData(data['1']),
                      builder: (context, snapshot) {
                        Map<String, dynamic> d =
                            snapshot.data!.data() as Map<String, dynamic>;

                        UserModel u = UserModel.fromMap(d);

                        return ListTile(
                          onTap: () {
                            Get.to(() => Chat(
                                  receiverUid: u.uid,
                                  chatId: user.chats[index],
                                ));
                          },
                          leading: u.pfpUrl != ''
                              ? CachedNetworkImage(
                                  imageUrl: u.pfpUrl!.toDecodedBase64,
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit.cover,
                                )
                              : const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                          title: u.username.text.bold.make(),
                          subtitle: data['lastMsgType'] == 'text'
                              ? _cipher.decryptData(data['lastMsg']).text.make()
                              : const Icon(Icons.image),
                        );
                      },
                    );
                  }

                  return ''.text.make();
                },
              );
            },
          ).p12()
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                'It seems that you have no chats to show.'
                    .text
                    .center
                    .bold
                    .bodyText1(context)
                    .make()
                    .pOnly(bottom: 20),
              ],
            ).p12(),
          );
  }
}
