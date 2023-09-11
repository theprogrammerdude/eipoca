import 'package:editable_image/editable_image.dart';
import 'package:eipoca/methods/auth.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/methods/upload.dart';
import 'package:eipoca/pages/account_settings.dart';
import 'package:eipoca/pages/edit_personal_details.dart';
import 'package:eipoca/pages/update_password.dart';
import 'package:eipoca/pages/view_photo.dart';
import 'package:eipoca/pages/welcome.dart';
import 'package:eipoca/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final Auth _auth = Auth();
  final Db _db = Db();
  final Local _local = Local();
  final Upload _upload = Upload();

  logout() {
    _auth.signout();
    _local.clean;
    Get.offAll(() => const Welcome());
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context).user;
    var joinedDt = Jiffy.parseFromMillisecondsSinceEpoch(user.createdAt).yMMMd;

    return Scaffold(
      appBar: AppBar(
        title: 'Profile'.text.bold.make(),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => ViewPhoto(
                      url: user.pfpUrl.toString(),
                    ),
                  );
                },
                child: EditableImage(
                  onChange: (file) async {
                    var url = await _upload.uploadImg(user.uid, file!);

                    _db.updatePfp(
                      user.uid,
                      url.toEncodedBase64,
                    );
                  },
                  editIconBackgroundColor: Vx.gray300,
                  image: user.pfpUrl != ''
                      ? Image.network(
                          user.pfpUrl!.toDecodedBase64,
                        )
                      : null,
                  imageDefaultBackgroundColor: Vx.gray100,
                ).pOnly(bottom: 25),
              ),
              '${user.firstname} ${user.lastname}'
                  .text
                  .capitalize
                  .bold
                  .headline6(context)
                  .make(),
              'Joined At: $joinedDt'.text.make().pOnly(bottom: 10),
              _auth.currentUser!.emailVerified == false
                  ? TextButton(
                      onPressed: () => _auth.sendVerificationMail(),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Vx.gray100),
                      ),
                      child: 'Verify your Email'.text.make(),
                    ).pOnly(bottom: 10)
                  : const SizedBox(height: 0),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Get.to(() => const EditPersonalDetails());
                      },
                      leading: const Icon(Icons.person),
                      title: 'Edit Personal Details'.text.make(),
                    ),
                    ListTile(
                      onTap: () {
                        Get.to(() => const UpdatePassword());
                      },
                      leading: const Icon(Icons.lock),
                      title: 'Update Password'.text.make(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.chat),
                      title: 'Chat Settings'.text.make(),
                    ),
                    ListTile(
                      onTap: () {
                        Get.to(() => const AccountSettings());
                      },
                      leading: const Icon(Icons.account_box),
                      title: 'Account Settings'.text.make(),
                    ),
                  ],
                ).p4(),
              ).pOnly(bottom: 10),
              // CustomButton(
              //   label: 'Logout',
              //   onPressed: () => logout(),
              // ),
            ],
          ).p12(),
        ),
      ),
    );
  }
}
