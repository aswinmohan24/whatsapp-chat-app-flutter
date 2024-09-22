import 'package:flutter/material.dart';
import 'package:whatsapp_clone/core/colors.dart';

class AppBarWidget extends StatelessWidget {
  final String appBarTitle;
  final double? fontSize;
  final FontWeight? fontWeight;
  const AppBarWidget(
      {super.key,
      required this.appBarTitle,
      required this.fontSize,
      required this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Text(
            appBarTitle,
            style: TextStyle(
                color: textColor, fontSize: fontSize, fontWeight: fontWeight),
          ),
          const Spacer(),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.qr_code_scanner_rounded,
                color: textColor,
              )),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: textColor,
              )),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert,
                color: textColor,
              ))
        ],
      ),
    );
  }
}
