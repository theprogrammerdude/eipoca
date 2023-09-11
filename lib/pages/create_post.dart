import 'dart:io';

import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/img.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/methods/upload.dart';
import 'package:eipoca/modules/cipher.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:xid/xid.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key, required this.serverId});

  final String serverId;

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final Local _local = Local();
  final Db _db = Db();
  final Img _img = Img();
  final Cipher _cipher = Cipher();
  final Upload _upload = Upload();

  var xid = Xid();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final TextEditingController _post = TextEditingController();

  ImageProvider<Object>? i;
  XFile? xfile;

  selectImgFromGallery() async {
    _img.pickImgFromGallery().then((value) {
      setState(() {
        xfile = value!;
      });

      _img.xFileToImg(value!).then((v) {
        setState(() {
          i = v;
        });
      });
    });
  }

  selectImgFromCamera() async {
    _img.pickImgFromCamera().then((value) {
      setState(() {
        xfile = value!;
      });

      _img.xFileToImg(value!).then((v) {
        setState(() {
          i = v;
        });
      });
    });
  }

  post() async {
    if (_formkey.currentState!.validate() || i != null) {
      Map<String, dynamic> d = {};

      Map<String, dynamic> data = {
        'post': _cipher.encryptData(_post.text.toLowerCase().trim()),
        'id': xid.toString(),
        'type': i == null ? 'text' : 'img',
        'creator': _local.getUid,
        'votes': 0,
        'downvotes': 0,
        'serverId': widget.serverId,
        'likes': []
      };

      if (i != null) {
        d = await _upload.uploadImgToPost(data, File(xfile!.path));

        await _db.addPostToServer({
          ...data,
          'url': d['url'].toString().toEncodedBase64,
          'xid': d['xid']
        });
      } else {
        await _db.addPostToServer(data);
      }

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Create Post'.text.make(),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => post(),
            child: Chip(
              label: 'Post'.text.white.make(),
              backgroundColor: context.primaryColor,
              shape: const StadiumBorder(),
            ).pOnly(right: 10),
          ),
        ],
      ),
      bottomNavigationBar: Row(
        children: [
          IconButton(
            onPressed: () => selectImgFromCamera(),
            icon: const Icon(
              Icons.camera_alt,
              size: 30,
              color: Colors.blueGrey,
            ),
          ),
          IconButton(
            onPressed: () => selectImgFromGallery(),
            icon: const Icon(
              Icons.image,
              size: 30,
              color: Colors.blueGrey,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.attach_file_rounded,
              size: 30,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ).p4(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formkey,
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Vx.gray200,
                  hintText: 'What\'s on your mind',
                  suffixIcon: IconButton(
                    onPressed: _post.clear,
                    icon: const Icon(Icons.clear),
                  ),
                ),
                validator: ValidationBuilder().required().build(),
                minLines: 1,
                maxLines: 5,
                maxLength: 250,
                controller: _post,
              ),
            ).pOnly(bottom: 10),
            i != null
                ? ZStack([
                    Image(
                      image: i!,
                    ).cornerRadius(8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          i = null;
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ).p4().backgroundColor(Vx.gray500).cornerRadius(20),
                    ).objectCenterRight(),
                  ])
                : const SizedBox(height: 0),
          ],
        ).p12(),
      ),
    );
  }
}
