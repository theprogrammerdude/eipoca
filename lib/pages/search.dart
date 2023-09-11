import 'package:cached_network_image/cached_network_image.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/models/server_model.dart';
import 'package:eipoca/models/user_model.dart';
import 'package:eipoca/pages/chat.dart';
import 'package:eipoca/pages/server_chat.dart';
import 'package:eipoca/providers/server_provider.dart';
import 'package:eipoca/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:velocity_x/velocity_x.dart';

class Search extends StatefulWidget {
  const Search({
    super.key,
    required this.type,
  });

  final int type;

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final Db _db = Db();
  final Local _local = Local();
  final Uuid _uuid = const Uuid();

  final TextEditingController _search = TextEditingController();

  search() {
    _db.searchServers(_search.text.toLowerCase()).listen((event) {
      List<ServerModel> servers = [];

      for (var element in event.docs) {
        ServerModel s = ServerModel.fromMap(element.data());
        servers.add(s);
      }

      if (_search.text.isNotEmptyAndNotNull) {
        Provider.of<ServerProvider>(context, listen: false)
            .updateServerList(servers);
      } else {
        Provider.of<ServerProvider>(context, listen: false)
            .updateServerList([]);
      }
    });
  }

  lookupUsers() {
    _db.searchPeople(_search.text.toLowerCase()).listen((event) {
      List<UserModel> users = [];

      for (var element in event.docs) {
        UserModel s = UserModel.fromMap(element.data());
        users.add(s);
      }

      if (_search.text.isNotEmptyAndNotNull) {
        Provider.of<ServerProvider>(context, listen: false)
            .updateUsersList(users);
      } else {
        Provider.of<ServerProvider>(context, listen: false).updateUsersList([]);
      }
    });
  }

  showOptions(ServerModel s) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Server Options'.text.bold.size(16).make().pSymmetric(v: 10),
            ListView(
              shrinkWrap: true,
              children: [
                s.participants.contains(_local.getUid)
                    ? ListTile(
                        onTap: () {
                          Get.back();
                          Get.to(() => ServerChat(id: s.id));
                        },
                        leading: const Icon(Icons.mark_chat_unread_rounded),
                        title: 'View Server'.text.make(),
                      )
                    : ListTile(
                        onTap: () {
                          _db.joinServer(s.id, _local.getUid).then((value) {
                            Get.back();
                            Get.to(() => ServerChat(id: s.id));
                          });
                        },
                        leading: const Icon(Icons.add),
                        title: 'Join Server'.text.make(),
                      ),
              ],
            ),
          ],
        ).wPCT(context: context, widthPCT: 100).p12();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var s = Provider.of<ServerProvider>(context).serversList;
    var u = Provider.of<ServerProvider>(context).usersList;

    return Scaffold(
      appBar: AppBar(
        title: 'Search'.text.bold.make(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Card(
            child: widget.type == 1
                ? CustomInput(
                    label: 'Search Server Tag',
                    prefixIcon: const Icon(Icons.search),
                    isObscure: false,
                    controller: _search,
                    onChanged: (p0) => search(),
                  )
                : CustomInput(
                    label: 'Search Chat',
                    prefixIcon: const Icon(Icons.search),
                    isObscure: false,
                    controller: _search,
                    onChanged: (p0) => lookupUsers(),
                  ),
          ),
          widget.type == 1
              ? Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: s.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () => showOptions(s[index]),
                        leading: s[index].serverPhotoURL != ''
                            ? CachedNetworkImage(
                                imageUrl: s[index].serverPhotoURL!,
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.tag),
                              ),
                        title: s[index].name.text.bold.capitalize.make(),
                      );
                    },
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: u.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          bool chatExists =
                              await _db.checkIfUserChatExists(_local.getUid);

                          if (chatExists) {
                            String chatId = await _db.getChatId(_local.getUid);

                            Get.to(() => Chat(
                                  receiverUid: u[index].uid,
                                  chatId: chatId,
                                ));
                          } else {
                            Get.to(() => Chat(
                                  receiverUid: u[index].uid,
                                  chatId: _uuid.v4().toEncodedBase64,
                                ));
                          }
                        },
                        leading: u[index].pfpUrl != ''
                            ? CachedNetworkImage(
                                imageUrl:
                                    u[index].pfpUrl.toString().toDecodedBase64,
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                        title: u[index].username.text.bold.capitalize.make(),
                      );
                    },
                  ),
                )
        ],
      ).p12(),
    );
  }
}
