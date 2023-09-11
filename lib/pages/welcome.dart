import 'package:eipoca/pages/login.dart';
import 'package:eipoca/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:velocity_x/velocity_x.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
              ),
              const SizedBox(
                height: 50,
              ),
              'Welcome to eipoca.'
                  .text
                  .bold
                  .headline4(context)
                  .make()
                  .pOnly(bottom: 10),
              'A new messenger and chat app, join new servers, make new friends, and chat across different servers.'
                  .text
                  .gray400
                  .center
                  .make(),
              const SizedBox(
                height: 50,
              ),
              CustomButton(
                label: 'Get Started',
                onPressed: () {
                  Get.to(() => const Login());
                },
              ),
            ],
          ).p12(),
        ),
      ),
    );
  }
}
