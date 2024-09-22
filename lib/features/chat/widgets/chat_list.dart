import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/providers/message_reply_provider.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/widgets/my_message_card.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/features/chat/widgets/sender_message_card.dart';

class ChatList extends ConsumerStatefulWidget {
  final String recieverUserId;
  final String profilePic;
  const ChatList(
      {super.key, required this.recieverUserId, required this.profilePic});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageScrollController = ScrollController();

  void onMessageSwipe(String message, bool isMe, MessageEnum messageEnum) {
    ref.read(messageReplyProvider.notifier).update(
          (state) => MessageReply(message, isMe, messageEnum),
        );
  }

  @override
  void dispose() {
    super.dispose();
    messageScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
        stream: ref
            .watch(chatControllerProvider)
            .getChatStream(widget.recieverUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          SchedulerBinding.instance.addPostFrameCallback((_) {
            messageScrollController
                .jumpTo(messageScrollController.position.maxScrollExtent);
          });
          return ListView.builder(
              controller: messageScrollController,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final messageData = snapshot.data![index];
                if (!messageData.isSeen &&
                    messageData.recieverId ==
                        FirebaseAuth.instance.currentUser!.uid) {
                  ref.read(chatControllerProvider).setChatMessageSeen(
                      context, messageData.recieverId, messageData.messageId);
                }
                if (messageData.senderId ==
                    FirebaseAuth.instance.currentUser!.uid) {
                  //return my message
                  return MyMessageCard(
                    message: messageData.text,
                    time: DateFormat('hh:mm a').format(messageData.timeSend),
                    type: messageData.type,
                    messageId: messageData.messageId,
                    senderprofilePic: widget.profilePic,
                    repliedText: messageData.repliedMessage,
                    repliedMessageType: messageData.repliedMessageType,
                    userName: messageData.repliedTo,
                    onLeftSwipe: () => onMessageSwipe(
                        messageData.text, true, messageData.type),
                    isSeen: messageData.isSeen,
                  );
                } else {
                  return SenderMessageCard(
                    message: messageData.text,
                    time: DateFormat('hh:mm a').format(messageData.timeSend),
                    type: messageData.type,
                    messageId: messageData.messageId,
                    imageUrl: messageData.text,
                    repliedMessageType: messageData.repliedMessageType,
                    repliedText: messageData.repliedMessage,
                    userName: messageData.repliedTo,
                    onLeftSwipe: () => onMessageSwipe(
                        messageData.text, false, messageData.type),
                  );
                }
                // else sender message card
              });
        });
  }
}
