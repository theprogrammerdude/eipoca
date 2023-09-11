import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Img {
  final ImagePicker _imagePicker = ImagePicker();

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
}
