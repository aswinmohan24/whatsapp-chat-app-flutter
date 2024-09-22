// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/core/colors.dart';
import 'package:whatsapp_clone/features/chat/widgets/display_text_image_gif.dart';

class SenderMessageCard extends StatelessWidget {
  final String message;
  final String time;
  final MessageEnum type;
  final String messageId;
  final String imageUrl;
  final VoidCallback onLeftSwipe;
  final String repliedText;
  final String userName;
  final MessageEnum repliedMessageType;
  const SenderMessageCard({
    super.key,
    required this.message,
    required this.time,
    required this.type,
    required this.messageId,
    required this.imageUrl,
    required this.onLeftSwipe,
    required this.repliedText,
    required this.userName,
    required this.repliedMessageType,
  });

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;
    return SwipeTo(
      onRightSwipe: (details) => onLeftSwipe(),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 45),
          child: Card(
            elevation: 1,
            color: senderMessageCardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsetsDirectional.symmetric(
                horizontal: 15, vertical: 5),
            child: Stack(
              children: [
                Padding(
                    padding: type == MessageEnum.text
                        ? type == MessageEnum.image
                            ? const EdgeInsets.only(
                                left: 5, right: 5, top: 5, bottom: 25)
                            : const EdgeInsets.only(
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
                                  borderRadius: BorderRadius.circular(8),
                                  border: const BorderDirectional(
                                      start: BorderSide(
                                          width: 4, color: Colors.green))),
                              child: DisplayTextImageGIF(
                                message: repliedText,
                                type: repliedMessageType,
                                messageId: messageId,
                                profilePic: imageUrl,
                              ),
                            ),
                          ],
                          DisplayTextImageGIF(
                            message: message,
                            type: type,
                            messageId: messageId,
                            profilePic: imageUrl,
                          ),
                        ],
                      ),
                    )),
                Positioned(
                    bottom: 4,
                    right: 10,
                    child: Text(
                      time,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white60),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
