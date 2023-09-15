// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'dart:typed_data';

import 'package:eipoca/modules/cipher.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xid/xid.dart';

class Img {
  final ImagePicker _imagePicker = ImagePicker();
  final Cipher _cipher = Cipher();
  final Xid _xid = Xid();

  Future<XFile?> pickImgFromGallery() async {
    XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    return file;
  }

  Future<XFile?> pickImgFromCamera() async {
    XFile? file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );

    return file;
  }

  Future<ImageProvider<Object>> xFileToImg(XFile f) async {
    final Uint8List bytes = await f.readAsBytes();
    return Image.memory(bytes).image;
  }

  Future<ShareResult> shareFile(String url) async {
    Uri uri = Uri.parse(_cipher.decryptData(url));
    final response = await http.get(uri);

    final documentDirectory = await getApplicationDocumentsDirectory();

    File f = await File(
      join(
        documentDirectory.path,
        '${_xid.toString()}.png',
      ),
    ).writeAsBytes(response.bodyBytes);

    XFile xf = XFile(f.path);
    return await Share.shareXFiles([xf]);
  }
}
