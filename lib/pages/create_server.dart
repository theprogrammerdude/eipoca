// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/modules/constants.dart';
import 'package:eipoca/widgets/custom_button.dart';
import 'package:eipoca/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/route_manager.dart';
import 'package:velocity_x/velocity_x.dart';

class CreateServer extends StatefulWidget {
  const CreateServer({super.key});

  @override
  State<CreateServer> createState() => _CreateServerState();
}

class _CreateServerState extends State<CreateServer> {
  final Db _db = Db();
  final Local _local = Local();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _tag = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  createServer() async {
    bool tagExists =
        await _db.checkIfServerTagExists(_tag.text.toLowerCase().trim());

    if (_formkey.currentState!.validate() && !tagExists) {
      Map<String, dynamic> data = {
        'name': _name.text.toLowerCase().trim(),
        'tag': _tag.text.toLowerCase().trim(),
        'createdBy': _local.getUid,
        'totalMembers': NUM_OF_MEMBERS,
        'serverPhotoURL': '',
        'serverBio': '',
        'participants': FieldValue.arrayUnion([_local.getUid]),
      };

      _db.createServer(data).then((value) {
        Get.back();
        VxToast.show(context, msg: 'Server created.');
      });
    } else if (tagExists) {
      VxToast.show(context, msg: 'Server tag already exists.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          'Create Server'.text.bold.headline4(context).make(),
          'Create a new server for your friends to chat.'
              .text
              .gray400
              .make()
              .pOnly(bottom: 15),
          Card(
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  CustomInput(
                    label: 'Server Name',
                    prefixIcon: const Icon(Icons.person),
                    controller: _name,
                    validator:
                        ValidationBuilder().required().minLength(4).build(),
                    isObscure: false,
                  ),
                  CustomInput(
                    label: 'Server Tag',
                    prefixIcon: const Icon(Icons.tag),
                    controller: _tag,
                    validator:
                        ValidationBuilder().required().minLength(4).build(),
                    isObscure: false,
                  ),
                ],
              ).p4(),
            ),
          ).pOnly(bottom: 20),
          'Click to create a new public server.'
              .text
              .gray400
              .make()
              .pOnly(bottom: 15),
          CustomButton(
            label: 'Create Server',
            onPressed: () => createServer(),
          )
        ],
      ).p12(),
    );
  }
}
