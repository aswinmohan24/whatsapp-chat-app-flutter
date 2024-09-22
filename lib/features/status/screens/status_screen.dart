import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/core/colors.dart';
import 'package:whatsapp_clone/features/status/controller/status_controller.dart';
import 'package:whatsapp_clone/features/status/screens/confirm_status_screen.dart';
import 'package:whatsapp_clone/features/status/screens/status_view_screen.dart';
import 'package:whatsapp_clone/models/status_models.dart';
import 'package:whatsapp_clone/widgets/mobile/appbar_widget.dart';

class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: size * .15,
            child: const AppBarWidget(
                appBarTitle: 'Updates',
                fontSize: 25,
                fontWeight: FontWeight.w300)),
        body: FutureBuilder<List<Status>>(
            future: ref.read(statusControllerProvider).getStatus(context),
            builder: (context, snapShot) {
              if (snapShot.connectionState == ConnectionState.waiting) {
                return const Loader();
              } else if (snapShot.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.no_photography_outlined,
                        color: kGreyColor,
                        size: 18,
                      ),
                      Text(
                        'No Status Updates',
                        style: TextStyle(fontSize: 18, color: kGreyColor),
                      )
                    ],
                  ),
                );
              }
              return ListView.builder(
                  itemCount: snapShot.data!.length,
                  itemBuilder: (context, index) {
                    var statusData = snapShot.data![index];
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, StatusViewScreen.routeName,
                            arguments: statusData);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            statusData.userName,
                            style: const TextStyle(fontSize: 18),
                          ),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(statusData.profilePic),
                            radius: 30,
                          ),
                        ),
                      ),
                    );
                  });
            }),
        floatingActionButton: FloatingActionButton(
          backgroundColor: floatingActionColor,
          onPressed: () async {
            File? pickedImage = await pickImageFromGallery(context);
            if (pickedImage != null) {
              if (context.mounted) {
                Navigator.pushNamed(context, ConfirmStatusScreen.routeName,
                    arguments: pickedImage);
              }
            }
          },
          child: const Icon(
            Icons.camera_alt,
            color: kBlackColor,
          ),
        ),
      ),
    );
  }
}
