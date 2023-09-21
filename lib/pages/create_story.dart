import 'dart:io';

import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/methods/upload.dart';
import 'package:eipoca/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jiffy/jiffy.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:vs_story_designer/vs_story_designer.dart';
import 'package:xid/xid.dart';

class CreateStory extends StatefulWidget {
  const CreateStory({super.key, required this.user});

  final UserModel user;

  @override
  State<CreateStory> createState() => _CreateStoryState();
}

class _CreateStoryState extends State<CreateStory> {
  final Local _local = Local();
  final Db _db = Db();
  final Xid _xid = Xid();
  final Upload _upload = Upload();

  add(String path) async {
    var id = _xid.toString();

    Map<String, dynamic> data = {
      'uid': _local.getUid,
      'ttl': Jiffy.now().add(hours: 24).millisecondsSinceEpoch,
      'id': id,
      'username': widget.user.username,
      'firstname': widget.user.firstname,
      'lastname': widget.user.lastname,
      'pfpUrl': widget.user.pfpUrl,
    };

    File file = File(path);

    String url = await _upload.uploadStory(data, file);
    data['url'] = url.toEncodedBase64;

    _db.addStory(data).then((value) {
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return VSStoryDesigner(
      onDone: (String uri) => add(uri),
      onDoneButtonStyle: const Icon(
        Iconsax.send_1,
        color: Colors.white,
      ).pOnly(right: 10),
      centerText: 'What\'s on your mind ...',
      fileName: _xid.toString(),
      middleBottomWidget: Container(),
    );
  }
}
