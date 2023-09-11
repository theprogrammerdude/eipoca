import 'dart:io';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/img.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/methods/upload.dart';
import 'package:eipoca/models/dm_model.dart';
import 'package:eipoca/models/user_model.dart';
import 'package:eipoca/modules/cipher.dart';
import 'package:eipoca/modules/utils.dart';
import 'package:eipoca/providers/dm_provider.dart';
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

class Chat extends StatefulWidget {
  const Chat({
    super.key,
    required this.receiverUid,
    required this.chatId,
  });

  final String receiverUid;
  final String chatId;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final Db _db = Db();
  final Local _local = Local();
  final Cipher _cipher = Cipher();
  final Utils _utils = Utils();
  final Img _img = Img();
  final Upload _upload = Upload();

  final TextEditingController _msg = TextEditingController();

  UserModel? receiver;

  @override
  void initState() {
    _db.getUserData(widget.receiverUid).listen((event) {
      Map<String, dynamic> d = event.data() as Map<String, dynamic>;
      receiver = UserModel.fromMap(d);

      setState(() {});
    });

    _db.getChats(widget.chatId).listen((event) {
      List<DmModel> dms = [];

      for (var element in event.docs) {
        DmModel c = DmModel.fromMap(element.data());
        dms.add(c);
      }

      Provider.of<DmProvider>(context, listen: false).updateChats(dms);
    });

    super.initState();
  }

  send({String? type, String? url, String? xid}) async {
    Map<String, dynamic> data = {
      'senderUid': _local.getUid,
      'receiverUid': widget.receiverUid,
      'type': type ?? 'text',
      'msg': type.isEmptyOrNull
          ? _cipher.encryptData(_msg.text.toLowerCase().trim())
          : '',
      'url': type != 'text' && type.isNotEmptyAndNotNull
          ? _cipher.encryptData(url!)
          : '',
      'xid': type == 'img' && type.isNotEmptyAndNotNull ? xid : '',
      'chatId': widget.chatId,
    };

    bool chatExists = await _db.checkIfUserChatExists(_local.getUid);

    if (!chatExists) {
      Map<String, dynamic> d = {
        'participants': [_local.getUid, widget.receiverUid],
        'chatId': widget.chatId,
      };

      _db.addParticipantsInChat(d);
    }

    _db.sendDM(data).then((value) {
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
              // if (selectedItem!.senderUid == _local.getUid) {
              //   if (selectedItem!.type == 'text' ||
              //       selectedItem!.type == 'url') {
              //     _db
              //         .deleteChat(selectedItem!.serverId, selectedItem!.id)
              //         .then((value) {
              //       setState(() {
              //         isItemSelected = false;
              //         selectedItem = null;
              //       });

              //       Navigator.pop(context);
              //     });
              //   } else {
              //     _upload
              //         .deleteImgFromServerChat(
              //             selectedItem!.serverId, selectedItem!.xid!)
              //         .then((value) {
              //       _db
              //           .deleteChat(selectedItem!.serverId, selectedItem!.id)
              //           .then((value) {});
              //       setState(() {
              //         isItemSelected = false;
              //         selectedItem = null;
              //       });

              //       Navigator.pop(context);
              //     });
              //   }
              // }
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
            // Text(Jiffy.parseFromMillisecondsSinceEpoch(selectedItem!.createdAt)
            //     .yMMMMdjm),
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
      // Map<String, String> r = await _upload.sendImgToServerChat(
      //   widget.id,
      //   File(file.path),
      // );

      // send(type: 'img', url: r['url'], xid: r['xid']);
    }
  }

  @override
  Widget build(BuildContext context) {
    var c = Provider.of<DmProvider>(context).chats;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: receiver!.pfpUrl != ''
                    ? CachedNetworkImage(
                        imageUrl: receiver!.pfpUrl!.toDecodedBase64,
                        height: 30,
                        width: 30,
                        fit: BoxFit.cover,
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
              ).p8(),
              receiver!.username.text.bold.make(),
            ],
          ),
        ),
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
              // .backgroundColor(selectedItem == c[index] ? Vx.gray100 : null)
              .cornerRadius(8);
        },
      ).p12(),
    );
  }
}
