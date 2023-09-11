import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:velocity_x/velocity_x.dart';

class Cipher {
  static final key = Key.fromUtf8(dotenv.env['AES_KEY']!);
  static final iv = IV.fromUtf8(dotenv.env['AES_IV']!);
  static final aesEncrypter = Encrypter(AES(key, mode: AESMode.cbc));

  String encryptData(final String s) {
    final encrypted = aesEncrypter.encrypt(s, iv: iv);
    return encrypted.base64.toEncodedBase64;
  }

  String decryptData(final String encrypted) {
    final data = aesEncrypter.decrypt64(encrypted.toDecodedBase64, iv: iv);
    return data;
  }
}
