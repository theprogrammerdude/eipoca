import 'package:eipoca/providers/user_provider.dart';
import 'package:eipoca/widgets/custom_button.dart';
import 'package:eipoca/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class EditPersonalDetails extends StatefulWidget {
  const EditPersonalDetails({super.key});

  @override
  State<EditPersonalDetails> createState() => _EditPersonalDetailsState();
}

class _EditPersonalDetailsState extends State<EditPersonalDetails> {
  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _email = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            'Edit Personal Information'
                .text
                .bold
                .headline4(context)
                .make()
                .objectCenterLeft(),
            'You can edit your personal information here.'
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
                      label: 'First Name',
                      prefixIcon: const Icon(Icons.person),
                      isObscure: false,
                      controller: _firstname..text = user.firstname.capitalized,
                    ),
                    CustomInput(
                      label: 'Last Name',
                      prefixIcon: const Icon(Icons.person),
                      isObscure: false,
                      controller: _lastname..text = user.lastname.capitalized,
                    ),
                    CustomInput(
                      label: 'Email',
                      prefixIcon: const Icon(Icons.mail),
                      isObscure: false,
                      controller: _email..text = user.email,
                      isEnabled: false,
                    ),
                  ],
                ).p4(),
              ),
            ).pOnly(bottom: 25),
            CustomButton(
              label: 'Update Details',
              onPressed: () {},
            ),
          ],
        ).p12(),
      ),
    );
  }
}
