import 'dart:io';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/img.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/methods/upload.dart';
import 'package:eipoca/models/chat_model.dart';
import 'package:eipoca/modules/cipher.dart';
import 'package:eipoca/modules/utils.dart';
import 'package:eipoca/pages/server_info.dart';
import 'package:eipoca/providers/server_provider.dart';
import 'package:eipoca/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class ServerChat extends StatefulWidget {
  const ServerChat({super.key, required this.id});

  final String id;

  @override
  State<ServerChat> createState() => _ServerChatState();
}

class _ServerChatState extends State<ServerChat> {
  final Db _db = Db();
  final Upload _upload = Upload();
  final Local _local = Local();
  final Cipher _cipher = Cipher();
  final Img _img = Img();
  final Utils _utils = Utils();

  final TextEditingController _msg = TextEditingController();

  bool isItemSelected = false;
  ChatModel? selectedItem;

  @override
  void initState() {
    _db.getServerInfo(widget.id).listen((event) {
      Map<String, dynamic> d = event.data() as Map<String, dynamic>;

      Provider.of<ServerProvider>(context, listen: false).updateServerInfo(d);
    });

    _db.getServerChats(widget.id).listen((event) {
      List<ChatModel> chats = [];

      for (var element in event.docs) {
        ChatModel c = ChatModel.fromMap(element.data());
        chats.add(c);
      }

      Provider.of<ServerProvider>(context, listen: false).updateChats(chats);
    });

    super.initState();
  }

  send({String? type, String? url, String? xid}) {
    Map<String, dynamic> data = {
      'senderUid': _local.getUid,
      'serverId': widget.id,
      'type': type ?? 'text',
      'msg': type.isEmptyOrNull
          ? _cipher.encryptData(_msg.text.toLowerCase().trim())
          : '',
      'url': type != 'text' && type.isNotEmptyAndNotNull
          ? _cipher.encryptData(url!)
          : '',
      'xid': type == 'img' && type.isNotEmptyAndNotNull ? xid : '',
    };

    _db.sendMessageToServer(data).then((value) {
      _msg.clear();
    });
  }

  deleteDialog() {
    showPlatformDialog(
      context: context,
      builder: (context) => BasicDialogAlert(
        title: const Text('Are you sure?'),
        content: const Text(
          'Deleting a text is irreversible, you won\'t be able to retreive it back.',
        ),
        actions: [
          BasicDialogAction(
            title: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          BasicDialogAction(
            title: const Text('I\'m Sure'),
            onPressed: () {
              if (selectedItem!.senderUid == _local.getUid) {
                if (selectedItem!.type == 'text' ||
                    selectedItem!.type == 'url') {
                  _db
                      .deleteChat(selectedItem!.serverId, selectedItem!.id)
                      .then((value) {
                    setState(() {
                      isItemSelected = false;
                      selectedItem = null;
                    });

                    Navigator.pop(context);
                  });
                } else {
                  _upload
                      .deleteImgFromServerChat(
                          selectedItem!.serverId, selectedItem!.xid!)
                      .then((value) {
                    _db
                        .deleteChat(selectedItem!.serverId, selectedItem!.id)
                        .then((value) {});
                    setState(() {
                      isItemSelected = false;
                      selectedItem = null;
                    });

                    Navigator.pop(context);
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  infoDialog() {
    showPlatformDialog(
      context: context,
      builder: (context) => BasicDialogAlert(
        title: const Text('Info'),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sent At: '),
            Text(Jiffy.parseFromMillisecondsSinceEpoch(selectedItem!.createdAt)
                .yMMMMdjm),
          ],
        ),
        actions: [
          BasicDialogAction(
            title: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          BasicDialogAction(
            title: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context);
              deleteDialog();
            },
          ),
        ],
      ),
    );
  }

  attach() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Attach Options'.text.bold.uppercase.make().pOnly(bottom: 15),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: [
                CustomIconButton(
                  onPressed: () {},
                  color: Colors.blue,
                  icon: Icons.camera_alt,
                ),
                CustomIconButton(
                  onPressed: () {
                    Get.back();
                    selectImgFromGallery();
                  },
                  color: Colors.purple,
                  icon: Icons.image_rounded,
                ),
                CustomIconButton(
                  onPressed: () {},
                  color: Colors.orange,
                  icon: Icons.image_rounded,
                ),
              ],
            )
          ],
        ).p12();
      },
    );
  }

  selectImgFromGallery() async {
    XFile? file = await _img.pickImgFromGallery();

    if (file != null) {
      Map<String, String> r = await _upload.sendImgToServerChat(
        widget.id,
        File(file.path),
      );

      send(type: 'img', url: r['url'], xid: r['xid']);
    }
  }

  @override
  Widget build(BuildContext context) {
    var s = Provider.of<ServerProvider>(context).serverInfo;
    var c = Provider.of<ServerProvider>(context).chats;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            Get.to(() => const ServerInfo());
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: s.serverPhotoURL != ''
                    ? CachedNetworkImage(
                        imageUrl: s.serverPhotoURL!.toDecodedBase64,
                        height: 30,
                        width: 30,
                        fit: BoxFit.cover,
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.tag),
                      ),
              ).p8(),
              s.name.capitalized.text.bold.make(),
            ],
          ),
        ),
        actions: [
          isItemSelected
              ? Row(
                  children: [
                    IconButton(
                      onPressed: () => infoDialog(),
                      icon: const Icon(Icons.info_outline_rounded),
                    ),
                    IconButton(
                      onPressed: () {
                        // setState(() {
                        //   isItemSelected = false;
                        //   selectedItem = null;
                        // });
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                )
              : const SizedBox(width: 0),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Write some message ...',
            filled: true,
            fillColor: Vx.gray200,
            counterText: '',
            suffixIcon: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => attach(),
                  icon: const Icon(Icons.attach_file),
                ),
                IconButton(
                  onPressed: () => _utils.isLink(_msg.text)
                      ? send(type: 'url', url: _msg.text)
                      : send(),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
          minLines: 1,
          maxLines: 5,
          controller: _msg,
        ).cornerRadius(10).p12(),
      ),
      body: ListView.builder(
        reverse: true,
        itemCount: c.length,
        itemBuilder: (context, index) {
          bool isSender = c[index].senderUid == _local.getUid;
          // var date =
          //     Jiffy.parseFromMillisecondsSinceEpoch(c[index].createdAt).Hms;

          return SwipeTo(
            onRightSwipe: () {
              // setState(() {
              //   isItemSelected = !isItemSelected;
              //   selectedItem = isItemSelected ? c[index] : null;
              // });
            },
            child: c[index].type == 'text'
                ? BubbleNormal(
                    text: _cipher.decryptData(c[index].msg).toString(),
                    isSender: isSender,
                    color: isSender ? context.primaryColor : Vx.gray100,
                    textStyle: TextStyle(
                      color: isSender ? Colors.white : Colors.black,
                    ),
                  )
                : c[index].type == 'img'
                    ? BubbleNormalImage(
                        id: c[index].id,
                        image: CachedNetworkImage(
                          imageUrl: _cipher.decryptData(c[index].url!),
                        ),
                      )
                    : AnyLinkPreview(
                        link: _cipher.decryptData(c[index].url!),
                        removeElevation: true,
                        urlLaunchMode: LaunchMode.inAppWebView,
                      ).p8(),
          )
              .backgroundColor(selectedItem == c[index] ? Vx.gray100 : null)
              .cornerRadius(8);
        },
      ).p12(),
    );
  }
}
