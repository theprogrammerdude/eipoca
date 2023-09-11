import 'package:eipoca/methods/auth.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/pages/welcome.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:velocity_x/velocity_x.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  final Auth _auth = Auth();
  final Db _db = Db();
  final Local _local = Local();

  deleteAccount() {
    _auth.deleteAccount().then((value) {
      _db.deleteUserData(_local.getUid);

      _local.clean;
      Get.offAll(() => const Welcome());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            'Account Settings'
                .text
                .bold
                .headline4(context)
                .make()
                .objectCenterLeft(),
            'View all your account related settings.'
                .text
                .gray400
                .make()
                .pOnly(bottom: 30),
            Card(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {},
                    leading: const Icon(Icons.delete),
                    title: 'Delete Account'.text.make(),
                    subtitle:
                        'Permanently delete your account. You wom\'t be able to recover it.'
                            .text
                            .make(),
                  ),
                  ListTile(
                    onTap: () {},
                    leading: const Icon(Icons.disabled_by_default_rounded),
                    title: 'Disable Account'.text.make(),
                    subtitle: 'Temporarily disable your account.'.text.make(),
                  ),
                  ListTile(
                    onTap: () {
                      _auth.signout().then((value) {
                        _local.clean;
                        Get.offAll(() => const Welcome());
                      });
                    },
                    leading: const Icon(Icons.logout_rounded),
                    title: 'Logout'.text.make(),
                  ),
                ],
              ).p4(),
            ).pOnly(bottom: 10),
          ],
        ).p12(),
      ),
    );
  }
}
