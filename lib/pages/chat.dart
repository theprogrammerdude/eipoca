// ignore_for_file: use_build_context_synchronously

import 'package:any_link_preview/any_link_preview.dart';
import 'package:avatars/avatars.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/img.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/methods/local_storage.dart';
import 'package:eipoca/methods/upload.dart';
import 'package:eipoca/models/dm_model.dart';
import 'package:eipoca/models/user_model.dart';
import 'package:eipoca/modules/cipher.dart';
import 'package:eipoca/providers/dm_provider.dart';
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
  final Upload _upload = Upload();
  final Img _img = Img();
  final LocalStorage _localStorage = LocalStorage();

  final TextEditingController _edit = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  UserModel? receiver;
  bool isReplying = false;
  String text = '';
  Map<String, dynamic>? chatDetailsFromLocal = {};

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

    getChatDetailsFromLocal();

    super.initState();
  }

  getChatDetailsFromLocal() async {
    Map<String, dynamic>? r = await _localStorage.getChat(widget.chatId);

    setState(() {
      chatDetailsFromLocal = r;
    });
  }

  deleteDialog(DmModel dm) {
    Get.back();

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
              if (dm.senderUid == _local.getUid) {
                if (dm.type == 'text' || dm.type == 'url') {
                  _db.deleteDM(dm.chatId, dm.id).then((value) {
                    Navigator.pop(context);
                  });
                } else {
                  _upload.deleteImgFromChat(dm.chatId, dm.xid!).then((value) {
                    _db.deleteDM(dm.chatId, dm.id).then((value) {
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

  options(DmModel dm) {
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
                dm.type == 'text'
                    ? ListTile(
                        onTap: () {
                          setState(() {
                            isReplying = true;
                            text = dm.msg;
                          });

                          Get.back();
                        },
                        leading: const Icon(Icons.reply),
                        title: 'Reply'.text.make(),
                      )
                    : const SizedBox(height: 0),
                ListTile(
                  onTap: () => infoDialog(dm),
                  leading: const Icon(Icons.info_outline_rounded),
                  title: 'Info'.text.make(),
                ),
                ListTile(
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: _cipher.decryptData(dm.msg)),
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
                dm.senderUid == _local.getUid && dm.type == 'text'
                    ? ListTile(
                        onTap: () {
                          setState(() {
                            isReplying = false;
                          });

                          Get.back();
                          edit(dm);
                        },
                        leading: const Icon(Icons.edit),
                        title: 'Edit'.text.make(),
                      )
                    : const SizedBox(width: 0),
                dm.type == 'img'
                    ? ListTile(
                        onTap: () async {
                          Get.back();
                          _img.shareFile(dm.url!);
                        },
                        leading: const Icon(Icons.share),
                        title: 'Share'.text.make(),
                      )
                    : const SizedBox(height: 0),
                ListTile(
                  onTap: () => deleteDialog(dm),
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

  edit(DmModel dm) {
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
                    controller: _edit..text = _cipher.decryptData(dm.msg),
                  ),
                ),
              ).pOnly(bottom: 10),
              CustomButton(
                label: 'Edit Message',
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    Map<String, dynamic> data = {
                      'chatId': widget.chatId,
                      'msg':
                          _cipher.encryptData(_edit.text.toLowerCase().trim()),
                      'id': dm.id,
                    };

                    _db.editMessage(data).then((value) {
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

  infoDialog(DmModel dm) {
    Get.back();

    var date = Jiffy.parseFromMillisecondsSinceEpoch(dm.createdAt).yMMMMEEEEdjm;

    NDialog(
      dialogStyle: DialogStyle(titleDivider: true),
      title: Row(
        children: [
          const Text('Info').pOnly(right: 10),
          dm.edited != null
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
    var c = Provider.of<DmProvider>(context).chats;

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
                      : Avatar(
                          name: receiver!.username,
                          shape: AvatarShape.circle(20),
                        ),
                ).p8(),
                receiver!.username.text.bold.make(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: ChatInput(
          receiverUid: widget.receiverUid,
          chatId: widget.chatId,
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
