// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomInput extends StatefulWidget {
  const CustomInput({
    Key? key,
    required this.label,
    required this.prefixIcon,
    this.suffixIcon,
    required this.isObscure,
    this.controller,
    this.type,
    this.isEnabled,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  final String label;
  final Icon prefixIcon;
  final IconButton? suffixIcon;
  final bool isObscure;
  final TextEditingController? controller;
  final TextInputType? type;
  final bool? isEnabled;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: widget.prefixIcon,
        label: widget.label.text.make(),
        suffixIcon: widget.suffixIcon,
      ),
      validator: widget.validator,
      enabled: widget.isEnabled,
      keyboardType: widget.type,
      controller: widget.controller,
      obscureText: widget.isObscure,
      onChanged: widget.onChanged,
    ).cornerRadius(10);
  }
}
