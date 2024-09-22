import 'package:flutter/material.dart';
import 'package:whatsapp_clone/core/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: tabColor,
            maximumSize: const Size(double.infinity, 50)),
        child: Text(
          text,
          style: const TextStyle(color: kBlackColor),
        ));
  }
}
