import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final Color color;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: ShapeDecoration(
        color: color,
        shape: const CircleBorder(),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 30,
          color: Colors.white,
        ),
        onPressed: onPressed,
      ),
    ).p24();
  }
}
