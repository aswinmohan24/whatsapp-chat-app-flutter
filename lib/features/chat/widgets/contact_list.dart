import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/core/colors.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatsapp_clone/models/chat_contact.dart';
import 'package:intl/intl.dart';

class ContactList extends ConsumerWidget {
  const ContactList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: StreamBuilder<List<ChatContact>>(
          stream: ref.watch(chatControllerProvider).getChatContacts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            }
            if (snapshot.data != null) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final chatContactData = snapshot.data![index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50,
                        child: FadeInAnimation(
                          child: InkWell(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context).push(PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) {
                                      var begin = const Offset(1.0, 0.0);
                                      var end = Offset.zero;
                                      var curve = Curves.ease;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      return SlideTransition(
                                          position: animation.drive(tween),
                                          child: MobileChatScreen(
                                            name: chatContactData.name,
                                            uid: chatContactData.contactID,
                                            image: chatContactData.profilePic,
                                          ));
                                    },
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      var begin = const Offset(1.0, 0.0);
                                      var end = Offset.zero;
                                      var curve = Curves.ease;

                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: child,
                                      );
                                    },
                                  ));
                                },
                                splashColor: Colors.transparent,
                                title: Text(
                                  chatContactData.name,
                                  style: const TextStyle(
                                      fontSize: 18, color: textColor),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 6,
                                  ),
                                  child: Text(chatContactData.lastMessage,
                                      style: const TextStyle(
                                          fontSize: 18, color: kGreyColor)),
                                ),
                                leading: CircleAvatar(
                                    backgroundColor: kGreyColor.shade700,
                                    radius: 23,
                                    backgroundImage: CachedNetworkImageProvider(
                                        chatContactData.profilePic,
                                        scale: 1)),
                                trailing: Text(
                                    DateFormat('hh:mm a')
                                        .format(chatContactData.timeSent),
                                    style: const TextStyle(
                                        fontSize: 13, color: kGreyColor)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            } else {
              return const SizedBox();
            }
          }),
    );
  }
}
