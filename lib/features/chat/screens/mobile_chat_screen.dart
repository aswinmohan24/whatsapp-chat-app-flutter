import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/core/colors.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/calls/controller/call_controller.dart';
import 'package:whatsapp_clone/features/calls/screens/call_pickup_screen.dart';
import 'package:whatsapp_clone/features/chat/widgets/bottom_chat_field.dart';
import 'package:whatsapp_clone/features/chat/widgets/chat_list.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chatscreen';
  final String name;
  final String uid;
  final String image;

  const MobileChatScreen(
      {super.key, required this.name, required this.uid, required this.image});

  void makeCall(WidgetRef ref, BuildContext context) {
    ref.read(callControllerProvider).makeCall(
          context,
          name,
          uid,
          image,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: CallPickUpScreen(
        scaffold: Scaffold(
          appBar: AppBar(
            backgroundColor: backgroundColor,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: textColor,
                )),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(
                            image,
                          ),
                          fit: BoxFit.cover)),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: StreamBuilder(
                      stream:
                          ref.read(authControllerProvider).userDataById(uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Loader();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                  color: textColor,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Text(
                              snapshot.data!.isOnline ? 'Online' : 'Offline',
                              style: const TextStyle(fontSize: 12),
                            )
                          ],
                        );
                      }),
                ),
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () => makeCall(ref, context),
                  icon: const Icon(
                    Icons.videocam_outlined,
                    color: textColor,
                    size: 27,
                  )),
              IconButton(
                  onPressed: () {},
                  icon: const FaIcon(
                    Icons.call_outlined,
                    color: textColor,
                    size: 27,
                  )),
              IconButton(
                  onPressed: () {},
                  icon: const FaIcon(
                    Icons.more_vert,
                    color: textColor,
                    size: 27,
                  ))
            ],
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/backgroundImage.png'))),
            child: Column(
              children: [
                //chatlist
                Expanded(
                    child: ChatList(
                  recieverUserId: uid,
                  profilePic: image,
                )),
                //textfield input
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: BottomChatField(
                    recieverUserId: uid,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
