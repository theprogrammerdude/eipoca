import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:eipoca/methods/auth.dart';
import 'package:eipoca/methods/db.dart';
import 'package:eipoca/methods/local.dart';
import 'package:eipoca/methods/messaging.dart';
import 'package:eipoca/modules/cipher.dart';
import 'package:eipoca/pages/home.dart';
import 'package:eipoca/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/route_manager.dart';
import 'package:get/utils.dart';
import 'package:jiffy/jiffy.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:velocity_x/velocity_x.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final Auth _auth = Auth();
  final Db _db = Db();
  final Messaging _messaging = Messaging();
  final Local _local = Local();
  final Cipher _cipher = Cipher();

  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _lastname = TextEditingController();
  final TextEditingController _dob = TextEditingController();

  final RoundedLoadingButtonController _buttonController =
      RoundedLoadingButtonController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final List<String> genders = ['Male', 'Female', 'Rather not say', 'Select'];
  String selectedValue = 'Select';

  createAccount() {
    if (_formkey.currentState!.validate()) {
      _auth
          .createAccountWithEmailAndPassword(
        widget.data['email'],
        widget.data['password'],
      )
          .then((value) async {
        final Map<String, dynamic> d = {
          'email': widget.data['email'],
          'username': widget.data['username'],
          'password': _cipher.encryptData(widget.data['password']),
          'firstname': _firstname.text.toLowerCase().trim(),
          'lastname': _lastname.text.toLowerCase().trim(),
          'dob': _dob.text,
          'uid': value.user!.uid,
          'permanentBan': false,
          'emailVerified': value.user!.emailVerified,
          'fcmToken': await _messaging.generateFCMToken,
          'pfpUrl': '',
          'bio': ''
        };

        _db.createUserInDb(d).then((v) {
          _local.saveUid(d['uid']);
          Get.offAll(() => const Home());
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            'Personal Information'
                .text
                .bold
                .headline4(context)
                .make()
                .objectCenterLeft()
                .pOnly(bottom: 10),
            'We are collectiong personal data to keep track of your profile.'
                .text
                .gray400
                .make()
                .pOnly(bottom: 30),
            Card(
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomInput(
                          label: 'First Name',
                          prefixIcon: const Icon(Icons.person),
                          controller: _firstname,
                          validator: ValidationBuilder().minLength(3).build(),
                          isObscure: false,
                        ).wPCT(context: context, widthPCT: 40),
                        CustomInput(
                          label: 'Last Name',
                          prefixIcon: const Icon(Icons.person),
                          controller: _lastname,
                          validator: ValidationBuilder().minLength(3).build(),
                          isObscure: false,
                        ).wPCT(context: context, widthPCT: 40),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        DateTime? d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2999),
                        );

                        _dob.text = Jiffy.parse(d.toString())
                            .format(pattern: 'dd MMM yyyy');
                      },
                      child: CustomInput(
                        label: 'Date of Birth',
                        isEnabled: false,
                        controller: _dob,
                        validator: ValidationBuilder().required().build(),
                        prefixIcon: const Icon(Icons.calendar_today),
                        isObscure: false,
                      ).wPCT(context: context, widthPCT: 100),
                    ),
                    DropdownButtonFormField2(
                      items: genders
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: e.text.make(),
                            ),
                          )
                          .toList(),
                      value: selectedValue,
                      barrierDismissible: true,
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: ValidationBuilder().required().build(),
                      decoration: InputDecoration(
                        label: 'Select your Gender'.text.make(),
                        border: InputBorder.none,
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          selectedValue = value.toString();
                        });
                      },
                    ).wPCT(context: context, widthPCT: 100),
                  ],
                ).p8(),
              ),
            ).pOnly(bottom: 25),
            RoundedLoadingButton(
              controller: _buttonController,
              onPressed: () => createAccount(),
              width: context.width,
              color: context.primaryColor,
              child: 'Login'.text.white.make(),
            ).wPCT(context: context, widthPCT: 100).pOnly(bottom: 10),
          ],
        ).p12(),
      ),
    );
  }
}
