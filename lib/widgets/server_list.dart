import 'package:cached_network_image/cached_network_image.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/models/server_model.dart';
import 'package:eipoca/pages/server_feed.dart';
import 'package:eipoca/providers/server_provider.dart';
import 'package:eipoca/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class ServerList extends StatefulWidget {
  const ServerList({super.key});

  @override
  State<ServerList> createState() => _ServerListState();
}

class _ServerListState extends State<ServerList> {
  final Db _db = Db();
  final Local _local = Local();

  @override
  void initState() {
    _db.getServersList(_local.getUid).listen((event) async {
      List<ServerModel> servers = [];

      for (var element in event.docs) {
        ServerModel s = ServerModel.fromMap(element.data());
        servers.add(s);
      }

      Provider.of<ServerProvider>(context, listen: false)
          .updateServerList(servers);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var s = Provider.of<ServerProvider>(context).serversList;

    return s.isNotEmpty
        ? ListView.builder(
            itemCount: s.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  Get.to(() => ServerFeed(id: s[index].id));
                },
                leading: s[index].serverPhotoURL != ''
                    ? CachedNetworkImage(
                        imageUrl: s[index].serverPhotoURL!.toDecodedBase64,
                        height: 30,
                        width: 30,
                        fit: BoxFit.cover,
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.tag),
                      ),
                title: s[index].name.text.bold.capitalize.make(),
              );
            },
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                'It seems that you haven\'t joined any servers yet.'
                    .text
                    .center
                    .bold
                    .bodyText1(context)
                    .make()
                    .pOnly(bottom: 20),
                CustomButton(
                  label: 'Join Server',
                  onPressed: () {},
                )
              ],
            ).p12(),
          );
  }
}
