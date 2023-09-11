import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/no-internet.png'),
            'No Internet Connection.\n You are not connected to the internet'
                .text
                .center
                .make(),
          ],
        ),
      ),
    );
  }
}
