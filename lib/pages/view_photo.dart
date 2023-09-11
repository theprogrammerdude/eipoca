// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:xid/xid.dart';

class ViewPhoto extends StatefulWidget {
  const ViewPhoto({super.key, required this.url});

  final String url;

  @override
  State<ViewPhoto> createState() => _ViewPhotoState();
}

class _ViewPhotoState extends State<ViewPhoto> {
  var xid = Xid();

  Future<PermissionStatus> get permission async {
    return await Permission.storage.request();
  }

  download() async {
    if (await permission.isGranted) {
      var res = await http.get(Uri.parse(widget.url.toDecodedBase64));
      var dir = await getApplicationDocumentsDirectory();
      var path = '${dir.path}/imgs';

      var ext = res.headers['content-type'].toString().split('/')[1];

      var filePathAndName = '${dir.path}/imgs/${xid.toString()}.$ext';

      await Directory(path).create(recursive: true);
      File file = File(filePathAndName);

      file.writeAsBytesSync(res.bodyBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => download(),
            icon: const Icon(
              Icons.download,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: PhotoView(
        imageProvider: NetworkImage(widget.url.toDecodedBase64),
      ),
    );
  }
}
