// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:eipoca/methods/auth.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/pages/create_new_account.dart';
import 'package:eipoca/pages/home.dart';
import 'package:eipoca/widgets/custom_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:velocity_x/velocity_x.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final Auth _auth = Auth();
  final Local _local = Local();
  final Db _db = Db();

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final RoundedLoadingButtonController _buttonController =
      RoundedLoadingButtonController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  signIn() async {
    if (_formkey.currentState!.validate()) {
      try {
        Map<String, dynamic> d = await _db
            .extractEmailFromUsername(_username.text.toLowerCase().trim());

        if (d.isNotEmpty) {
          _auth.signInWithEmail(d['email'], _password.text).then((value) {
            _local.saveUid(value.user!.uid);
            Get.offAll(() => const Home());
          });
        } else {
          _buttonController.reset();
          VxToast.show(context, msg: 'No User Record Found');
        }
      } on FirebaseAuthException catch (e) {
        _buttonController.reset();
        log(e.toString());
      }
    } else {
      _buttonController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/logo.png',
              ),
              'Login to your Account.'
                  .text
                  .bold
                  .headline4(context)
                  .make()
                  .pSymmetric(v: 30),
              Card(
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      CustomInput(
                        label: 'Username',
                        controller: _username,
                        validator: ValidationBuilder()
                            .minLength(
                              4,
                              'Username must be greater than 4 characters',
                            )
                            .build(),
                        prefixIcon: const Icon(Icons.person),
                        isObscure: false,
                      ),
                      CustomInput(
                        label: 'Password',
                        controller: _password,
                        validator: ValidationBuilder()
                            .regExp(
                              RegExp(
                                '^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*]).{6,}\$',
                              ),
                              'Invalid Password',
                            )
                            .minLength(6)
                            .build(),
                        prefixIcon: const Icon(Icons.lock),
                        isObscure: true,
                      ),
                    ],
                  ).p8(),
                ),
              ).pOnly(bottom: 15),
              RoundedLoadingButton(
                controller: _buttonController,
                onPressed: () => signIn(),
                width: context.width,
                color: context.primaryColor,
                child: 'Login'.text.white.make(),
              ).wPCT(context: context, widthPCT: 100).pOnly(bottom: 10),
              GestureDetector(
                onTap: () {
                  Get.to(() => const CreateNewAccount());
                },
                child: 'Create New Account'
                    .text
                    .color(context.primaryColor)
                    .make()
                    .objectCenterRight(),
              ),
            ],
          ).p12(),
        ),
      ),
    );
  }
}
