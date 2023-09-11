import 'package:get_storage/get_storage.dart';

class Local {
  static final box = GetStorage();

  Future saveUid(String uid) async {
    return await box.write('uid', uid);
  }

  String get getUid => box.read('uid') ?? '';
  Future get clean => box.erase();
}
