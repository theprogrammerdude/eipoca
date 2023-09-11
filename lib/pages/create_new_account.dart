import 'package:eipoca/pages/personal_info.dart';
import 'package:eipoca/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:velocity_x/velocity_x.dart';

class CreateNewAccount extends StatefulWidget {
  const CreateNewAccount({super.key});

  @override
  State<CreateNewAccount> createState() => CreateNewAccountState();
}

class CreateNewAccountState extends State<CreateNewAccount> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final RoundedLoadingButtonController _buttonController =
      RoundedLoadingButtonController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  proceed() {
    if (_formkey.currentState!.validate()) {
      Map<String, dynamic> data = {
        'username': _username.text.toLowerCase(),
        'email': _email.text.toLowerCase(),
        'password': _password.text,
      };

      Get.to(() => PersonalInfo(data: data));
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
                'assets/e.jpeg',
                height: 200,
              ).cornerRadius(10),
              'Create a new Account.'
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
                              'Username must be greater than 5 characters',
                            )
                            .build(),
                        prefixIcon: const Icon(Icons.person),
                        isObscure: false,
                      ),
                      CustomInput(
                        label: 'Email',
                        controller: _email,
                        validator: ValidationBuilder().email().build(),
                        prefixIcon: const Icon(Icons.mail),
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
                onPressed: () => proceed(),
                width: context.width,
                color: context.primaryColor,
                child: 'Create New Account'.text.white.make(),
              ).wPCT(context: context, widthPCT: 100).pOnly(bottom: 10),
            ],
          ).p12(),
        ),
      ),
    );
  }
}
