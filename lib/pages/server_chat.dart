// ignore_for_file: use_build_context_synchronously

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
import 'package:eipoca/pages/server_info.dart';
import 'package:eipoca/providers/server_provider.dart';
import 'package:eipoca/reply_notif.dart';
import 'package:eipoca/widgets/chat_input.dart';
import 'package:eipoca/widgets/custom_button.dart';
import 'package:eipoca/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
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

  final TextEditingController _edit = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  ChatModel? selectedItem;
  bool isReplying = false;
  String text = '';

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

  deleteDialog(ChatModel chat) {
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
              if (chat.senderUid == _local.getUid) {
                if (chat.type == 'text' || chat.type == 'url') {
                  _db.deleteChat(chat.serverId, chat.id).then((value) {
                    Navigator.pop(context);
                  });
                } else {
                  _upload
                      .deleteImgFromServerChat(chat.serverId, chat.xid!)
                      .then((value) {
                    _db.deleteChat(chat.serverId, chat.id).then((value) {
                      Navigator.pop(context);
                    });
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // infoDialog(ChatModel chat) {
  //   showPlatformDialog(
  //     context: context,
  //     builder: (context) => BasicDialogAlert(
  //       title: const Text('Info'),
  //       content: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Text('Sent At: '),
  //           Text(Jiffy.parseFromMillisecondsSinceEpoch(selectedItem!.createdAt)
  //               .yMMMMdjm),
  //         ],
  //       ),
  //       actions: [
  //         BasicDialogAction(
  //           title: const Text('OK'),
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //         ),
  //         BasicDialogAction(
  //           title: const Text('Delete'),
  //           onPressed: () {
  //             Navigator.pop(context);
  //             deleteDialog(chat);
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  options(ChatModel chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Options'.text.bold.headline6(context).make(),
            ListView(
              shrinkWrap: true,
              children: [
                chat.type == 'text'
                    ? ListTile(
                        onTap: () {
                          setState(() {
                            isReplying = true;
                            text = chat.msg;
                          });

                          Get.back();
                        },
                        leading: const Icon(Icons.reply),
                        title: 'Reply'.text.make(),
                      )
                    : const SizedBox(height: 0),
                ListTile(
                  onTap: () => infoDialog(chat),
                  leading: const Icon(Icons.info_outline_rounded),
                  title: 'Info'.text.make(),
                ),
                ListTile(
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: _cipher.decryptData(chat.msg)),
                    );

                    Get.back();
                    VxToast.show(
                      context,
                      msg: 'Copied to Clipboard',
                      bgColor: Vx.gray800,
                      textColor: Colors.white,
                      position: VxToastPosition.center,
                    );
                  },
                  leading: const Icon(Icons.copy),
                  title: 'Copy'.text.make(),
                ),
                chat.senderUid == _local.getUid && chat.type == 'text'
                    ? ListTile(
                        onTap: () {
                          setState(() {
                            isReplying = false;
                          });

                          Get.back();
                          edit(chat);
                        },
                        leading: const Icon(Icons.edit),
                        title: 'Edit'.text.make(),
                      )
                    : const SizedBox(width: 0),
                chat.type == 'img'
                    ? ListTile(
                        onTap: () async {
                          Get.back();
                          _img.shareFile(chat.url!);
                        },
                        leading: const Icon(Icons.share),
                        title: 'Share'.text.make(),
                      )
                    : const SizedBox(height: 0),
                ListTile(
                  onTap: () => deleteDialog(chat),
                  leading: const Icon(Icons.delete),
                  title: 'Delete'.text.make(),
                ),
              ],
            )
          ],
        ).p12();
      },
    );
  }

  edit(ChatModel chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              'Edit Message'.text.bold.headline6(context).make(),
              Card(
                child: Form(
                  key: _formkey,
                  child: CustomInput(
                    label: 'Edit',
                    prefixIcon: const Icon(Icons.edit),
                    isObscure: false,
                    validator: ValidationBuilder().required().build(),
                    controller: _edit..text = _cipher.decryptData(chat.msg),
                  ),
                ),
              ).pOnly(bottom: 10),
              CustomButton(
                label: 'Edit Message',
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    Map<String, dynamic> data = {
                      'serverId': widget.id,
                      'msg':
                          _cipher.encryptData(_edit.text.toLowerCase().trim()),
                      'id': chat.id,
                    };

                    _db.editServerMessage(data).then((value) {
                      Get.back();
                    });
                  }
                },
              )
            ],
          ).p12(),
        );
      },
    );
  }

  infoDialog(ChatModel chat) {
    Get.back();

    var date =
        Jiffy.parseFromMillisecondsSinceEpoch(chat.createdAt).yMMMMEEEEdjm;

    NDialog(
      dialogStyle: DialogStyle(titleDivider: true),
      title: Row(
        children: [
          const Text('Info').pOnly(right: 10),
          chat.edited != null
              ? const Text(
                  '( Edited )',
                  style: TextStyle(fontSize: 12),
                )
              : const SizedBox(height: 0),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            children: [
              const Text(
                'Created At : ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(date.toString()),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Okay'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    var s = Provider.of<ServerProvider>(context).serverInfo;
    var c = Provider.of<ServerProvider>(context).chats;

    return NotificationListener<ReplyNotif>(
      onNotification: (notification) {
        setState(() {
          isReplying = notification.val;
        });

        return true;
      },
      child: Scaffold(
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
        ),
        bottomNavigationBar: ChatInput(
          serverId: widget.id,
          isReplying: isReplying,
          text: isReplying ? text : '',
        ),
        body: ListView.builder(
          reverse: true,
          itemCount: c.length,
          itemBuilder: (context, index) {
            bool isSender = c[index].senderUid == _local.getUid;

            return GestureDetector(
              onLongPress: () => options(c[index]),
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
            ).cornerRadius(8);
          },
        ).p12(),
      ),
    );
  }
}
