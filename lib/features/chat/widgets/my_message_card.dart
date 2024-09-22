import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/core/colors.dart';
import 'package:whatsapp_clone/features/chat/widgets/display_text_image_gif.dart';

class MyMessageCard extends StatelessWidget {
  final String message;
  final String time;
  final MessageEnum type;
  final String messageId;
  final String senderprofilePic;
  final VoidCallback onLeftSwipe;
  final String repliedText;
  final String userName;
  final MessageEnum repliedMessageType;
  final bool isSeen;

  const MyMessageCard({
    super.key,
    required this.message,
    required this.time,
    required this.type,
    required this.messageId,
    required this.senderprofilePic,
    required this.onLeftSwipe,
    required this.repliedText,
    required this.userName,
    required this.repliedMessageType,
    required this.isSeen,
  });

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;
    return SwipeTo(
      onRightSwipe: (details) => onLeftSwipe(),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 55,
              maxHeight: MediaQuery.of(context).size.height * 0.30,
              minWidth: MediaQuery.of(context).size.width * 0.35),
          child: Card(
            elevation: 1,
            color: myMessageCardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsetsDirectional.symmetric(
                horizontal: 15, vertical: 5),
            child: Stack(
              children: [
                Padding(
                    padding: type == MessageEnum.text
                        ? const EdgeInsets.only(
                            left: 10, right: 30, top: 5, bottom: 20)
                        : const EdgeInsets.only(
                            left: 5, right: 5, top: 5, bottom: 25),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (isReplying) ...[
                            // Text(
                            //   userName,
                            //   style: const TextStyle(fontWeight: FontWeight.bold),
                            // ),
                            Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width - 20,
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.30,
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.25),
                              padding: const EdgeInsetsDirectional.all(10),
                              decoration: BoxDecoration(
                                  color: myMessageReplyCardColor,
                                  borderRadius: BorderRadius.circular(6),
                                  border: const BorderDirectional(
                                      start: BorderSide(
                                          width: 4.5, color: Colors.green))),
                              child: DisplayTextImageGIF(
                                message: repliedText,
                                type: repliedMessageType,
                                messageId: messageId,
                                profilePic: senderprofilePic,
                              ),
                            ),
                          ],
                          DisplayTextImageGIF(
                            message: message,
                            type: type,
                            messageId: messageId,
                            profilePic: senderprofilePic,
                          ),
                        ],
                      ),
                    )),
                Positioned(
                    bottom: 4,
                    right: 10,
                    child: Row(
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white60),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Icon(
                          isSeen ? Icons.done_all : Icons.done,
                          color: isSeen ? Colors.blue : Colors.white60,
                          size: 15,
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
