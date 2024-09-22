import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_clone/core/colors.dart';

//--fucntion for showing snackbar---//
showSnackBAr({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: senderMessageColor,
      content: Text(
        content,
        style: const TextStyle(color: textColor),
      )));
}

//----function for image picker, picking image from gallery---//

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
    return image;
  } catch (e) {
    if (context.mounted) {
      showSnackBAr(context: context, content: e.toString());
    }
    return null;
  }
}

Future<File?> pickVideoFromGallery(BuildContext context) async {
  File? video;
  try {
    final pickedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedVideo != null) {
      video = File(pickedVideo.path);
    }
    return video;
  } catch (e) {
    if (context.mounted) {
      showSnackBAr(context: context, content: e.toString());
    }
    return null;
  }
}
