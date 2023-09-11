import 'package:cached_network_image/cached_network_image.dart';
import 'package:editable_image/editable_image.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/upload.dart';
import 'package:eipoca/models/server_model.dart';
import 'package:eipoca/models/user_model.dart';
import 'package:eipoca/providers/server_provider.dart';
import 'package:eipoca/widgets/custom_button.dart';
import 'package:eipoca/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class ServerInfo extends StatefulWidget {
  const ServerInfo({super.key});

  @override
  State<ServerInfo> createState() => _ServerInfoState();
}

class _ServerInfoState extends State<ServerInfo> {
  final Upload _upload = Upload();
  final Db _db = Db();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _bio = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  viewMembers(ServerModel s) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: 5,
          children: s.participants.map((e) {
            return StreamBuilder(
              stream: _db.getUserData(e),
              builder: (context, snapshot) {
                UserModel u = UserModel.fromMap(
                    snapshot.data!.data() as Map<String, dynamic>);

                return ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    imageUrl: u.pfpUrl!.toDecodedBase64,
                    height: 30,
                    width: 30,
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      return const CircleAvatar(
                        child: Icon(Icons.person),
                      );
                    },
                  ),
                );
              },
            );
          }).toList(),
        ).p12();
      },
    );
  }

  nameSheet(ServerModel s) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              'Change Name'
                  .text
                  .bold
                  .headline6(context)
                  .make()
                  .pOnly(bottom: 15),
              Card(
                color: Vx.gray200,
                child: Form(
                  key: _formkey,
                  child: CustomInput(
                    label: 'Name',
                    prefixIcon: const Icon(Icons.tag),
                    isObscure: false,
                    controller: _name,
                    validator: ValidationBuilder().required().build(),
                  ),
                ),
              ).pOnly(bottom: 10),
              CustomButton(
                label: 'Update',
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    Map<String, dynamic> data = {
                      'id': s.id,
                      'name': _name.text.toLowerCase()
                    };

                    _db.changeServerName(data).then((value) {
                      _bio.clear();
                      Get.back();
                    });
                  }
                },
              ),
            ],
          ).p12(),
        );
      },
    );
  }

  bioSheet(ServerModel s) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              'Change Bio'
                  .text
                  .bold
                  .headline6(context)
                  .make()
                  .pOnly(bottom: 15),
              Card(
                color: Vx.gray200,
                child: Form(
                  key: _formkey,
                  child: CustomInput(
                    label: 'Bio',
                    prefixIcon: const Icon(Icons.description),
                    isObscure: false,
                    controller: _bio,
                    validator: ValidationBuilder().required().build(),
                  ),
                ),
              ).pOnly(bottom: 10),
              CustomButton(
                label: 'Update',
                onPressed: () {
                  if (_formkey.currentState!.validate()) {
                    Map<String, dynamic> data = {
                      'id': s.id,
                      'bio': _bio.text.toLowerCase()
                    };

                    _db.changeServerBio(data).then((value) {
                      _bio.clear();
                      Get.back();
                    });
                  }
                },
              ),
            ],
          ).p12(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var s = Provider.of<ServerProvider>(context).serverInfo;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.volume_off_rounded,
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  child: Text('Leave Server'),
                ),
                const PopupMenuItem(
                  child: Text('Delete Server'),
                ),
              ];
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {},
                child: EditableImage(
                  onChange: (file) async {
                    var url = await _upload.uploadServerPhoto(s.id, file!);

                    _db.updateServerPhoto(
                      s.id,
                      url.toEncodedBase64,
                    );
                  },
                  imageDefault: Icons.tag,
                  editIconBackgroundColor: Vx.gray300,
                  image: s.serverPhotoURL.isNotEmptyAndNotNull
                      ? Image.network(
                          s.serverPhotoURL!.toDecodedBase64,
                          fit: BoxFit.cover,
                        )
                      : null,
                  imageDefaultBackgroundColor: Vx.gray100,
                ).pOnly(bottom: 25),
              ),
              s.name.text.capitalize.bold.headline6(context).make(),
              '#${s.tag}'.text.make(),
              s.bio!.text.center.gray500.wrapWords(true).make(),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () => viewMembers(s),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Vx.gray100,
                  ),
                ),
                child: 'View Members'.text.make(),
              ).pOnly(bottom: 10),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => nameSheet(s),
                      leading: const Icon(Icons.tag),
                      title: 'Change Server Name'.text.make(),
                    ),
                    ListTile(
                      onTap: () => bioSheet(s),
                      leading: const Icon(Icons.description),
                      title: 'Change Server Bio'.text.make(),
                    ),
                  ],
                ).p4(),
              ).pOnly(bottom: 10),
            ],
          ).p12(),
        ),
      ),
    );
  }
}
