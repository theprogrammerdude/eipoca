import 'package:eipoca/methods/auth.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/models/user_model.dart';
import 'package:eipoca/modules/cipher.dart';
import 'package:eipoca/providers/user_provider.dart';
import 'package:eipoca/widgets/custom_button.dart';
import 'package:eipoca/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final Auth _auth = Auth();
  final Db _db = Db();
  final Cipher _cipher = Cipher();

  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  encrypt(String s) {
    return _cipher.encryptData(s);
  }

  updatePassword(UserModel user) {
    if (_currentPassword.text == _newPassword.text) {
      VxToast.show(
        context,
        msg: 'New Password can\'t be same as Current Password',
      );
    } else if (_formkey.currentState!.validate() &&
        _newPassword.text == _confirmPassword.text) {
      _auth.signInWithEmail(user.email, _currentPassword.text).then((value) {
        _auth.updatePassword(_newPassword.text).then((value) {
          _db.updatePaswordInDb(
            user.uid,
            encrypt(_newPassword.text),
          );

          Get.back();

          VxToast.show(
            context,
            msg: 'Password Updated',
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            'Update Password'
                .text
                .bold
                .headline4(context)
                .make()
                .objectCenterLeft(),
            'Update your existing password. The password should be at least 6 characters in length, must have one uppercase chatracter, one lowercase character, one special character and at least one number.'
                .text
                .gray400
                .make()
                .pOnly(bottom: 30),
            Card(
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    CustomInput(
                      label: 'Current Password',
                      prefixIcon: const Icon(Icons.lock),
                      isObscure: true,
                      validator: ValidationBuilder()
                          .regExp(
                            RegExp(
                              '^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*]).{6,}\$',
                            ),
                            'Invalid Password',
                          )
                          .minLength(6)
                          .build(),
                      controller: _currentPassword,
                    ),
                    CustomInput(
                      label: 'New Password',
                      prefixIcon: const Icon(Icons.lock),
                      isObscure: true,
                      validator: ValidationBuilder()
                          .regExp(
                            RegExp(
                              '^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*]).{6,}\$',
                            ),
                            'Invalid Password',
                          )
                          .minLength(6)
                          .build(),
                      controller: _newPassword,
                    ),
                    CustomInput(
                      label: 'Update Password',
                      prefixIcon: const Icon(Icons.lock),
                      isObscure: true,
                      validator: ValidationBuilder()
                          .regExp(
                            RegExp(
                              '^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*]).{6,}\$',
                            ),
                            'Invalid Password',
                          )
                          .minLength(6)
                          .build(),
                      controller: _confirmPassword,
                    ),
                  ],
                ).p4(),
              ),
            ).pOnly(bottom: 25),
            CustomButton(
              label: 'Update Password',
              onPressed: () => updatePassword(user),
            ),
          ],
        ).p12(),
      ),
    );
  }
}
