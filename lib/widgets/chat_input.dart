import 'dart:io';

import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/img.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/methods/upload.dart';
import 'package:eipoca/modules/cipher.dart';
import 'package:eipoca/modules/utils.dart';
import 'package:eipoca/reply_notif.dart';
import 'package:eipoca/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    this.receiverUid,
    this.chatId,
    this.serverId,
    this.isReplying,
    this.text,
  });

  final String? receiverUid;
  final String? chatId;
  final String? serverId;
  final bool? isReplying;
  final String? text;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final Img _img = Img();
  final Utils _utils = Utils();
  final Local _local = Local();
  final Cipher _cipher = Cipher();
  final Db _db = Db();
  final Upload _upload = Upload();

  final TextEditingController _msg = TextEditingController();

  sendDm({String? type, String? url, String? xid}) async {
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

  sendToServer({String? type, String? url, String? xid}) {
    Map<String, dynamic> data = {
      'senderUid': _local.getUid,
      'serverId': widget.serverId,
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
                  onPressed: () {
                    Get.back();
                    selectImgFromCamera();
                  },
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

    if (file != null && widget.chatId.isNotEmptyAndNotNull) {
      Map<String, String> r = await _upload.sendImgToChat(
        widget.chatId!,
        File(file.path),
      );

      sendDm(type: 'img', url: r['url'], xid: r['xid']);
    } else if (file != null && widget.serverId.isNotEmptyAndNotNull) {
      Map<String, String> r = await _upload.sendImgToChat(
        widget.serverId!,
        File(file.path),
      );

      sendToServer(type: 'img', url: r['url'], xid: r['xid']);
    }
  }

  selectImgFromCamera() async {
    XFile? file = await _img.pickImgFromCamera();

    if (file != null && widget.chatId.isNotEmptyAndNotNull) {
      Map<String, String> r = await _upload.sendImgToChat(
        widget.chatId!,
        File(file.path),
      );

      sendDm(type: 'img', url: r['url'], xid: r['xid']);
    } else if (file != null && widget.serverId.isNotEmptyAndNotNull) {
      Map<String, String> r = await _upload.sendImgToChat(
        widget.serverId!,
        File(file.path),
      );

      sendToServer(type: 'img', url: r['url'], xid: r['xid']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                onPressed: () {
                  if (widget.isReplying!) {
                    ReplyNotif(false).dispatch(context);
                  }

                  widget.chatId.isNotEmptyAndNotNull
                      ? _utils.isLink(_msg.text)
                          ? sendDm(type: 'url', url: _msg.text)
                          : sendDm()
                      : _utils.isLink(_msg.text)
                          ? sendToServer(type: 'url', url: _msg.text)
                          : sendToServer();
                },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
        minLines: 1,
        maxLines: 5,
        controller: _msg
          ..text = widget.isReplying!
              ? '${_cipher.decryptData(widget.text!)} \n \n'
              : '',
      ).cornerRadius(10).p12(),
    );
  }
}
