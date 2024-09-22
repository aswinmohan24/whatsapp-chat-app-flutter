import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/core/colors.dart';
import 'package:whatsapp_clone/core/constants.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  static const routeName = '/user-info';
  const UserInfoScreen({super.key});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  File? image;
  bool isSaving = false;
  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void storeUserData() async {
    String name = nameController.text.trim();
    setState(() {
      isSaving = true;
    });
    ref.read(authControllerProvider).saveDatatoFirebase(context, name, image);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                image == null
                    ? CircleAvatar(
                        radius: 75,
                        backgroundColor: kGreyColor,
                        backgroundImage: AssetImage(
                          defaultUserInfoImage,
                        ))
                    : CircleAvatar(
                        radius: 65,
                        backgroundColor: kGreyColor,
                        backgroundImage: FileImage(
                          image!,
                        )),
                Positioned(
                  left: 90,
                  bottom: -10,
                  child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                        color: textColor,
                      )),
                )
              ],
            ),
            Row(
              children: [
                Container(
                  width: size.width * .85,
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(hintText: 'Enter your name'),
                  ),
                ),
                isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: myMessageCardColor,
                        ),
                      )
                    : IconButton(
                        onPressed: storeUserData,
                        icon: const Icon(
                          Icons.done,
                        ))
              ],
            )
          ],
        ),
      )),
    );
  }
}
