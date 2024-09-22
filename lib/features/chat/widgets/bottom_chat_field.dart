import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/providers/message_reply_provider.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/core/colors.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:flutter_sound/flutter_sound.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String recieverUserId;
  const BottomChatField({super.key, required this.recieverUserId});

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  String message = '';
  bool isEmojiBoxShowing = false;
  FocusNode focusNode = FocusNode();
  TextEditingController messageController = TextEditingController();
  FlutterSoundRecorder? soundRecorder;
  bool isRecordInit = false;
  bool isRecording = false;

  void openAudio() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone Permission Not Allowed');
    } else {
      await soundRecorder!.openRecorder();
      setState(() {
        isRecordInit = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    soundRecorder = FlutterSoundRecorder();
    openAudio();
  }
//------functions for displaying keboard and emoji picker in bottom-------------//

  void hideEmojiContainer() {
    setState(() {
      isEmojiBoxShowing = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isEmojiBoxShowing = true;
    });
  }

  void toggleEmojiKeyboard() {
    if (isEmojiBoxShowing) {
      showKeyBoard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  void showKeyBoard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  //------END-------//

  //------functions for sending text message and audio recording to firebase in single button press in whatsapp send and mic button-------//

  void sendTextMessage() async {
    if (message.isNotEmpty) {
      ref.read(chatControllerProvider).sendTextMessage(
          context, messageController.text, widget.recieverUserId);
      setState(() {
        messageController.text = '';
        message = '';
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';

      if (!isRecordInit) {
        return;
      }
      if (isRecording) {
        await soundRecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await soundRecorder!.startRecorder(toFile: path);
      }
      setState(() {
        isRecording = !isRecording;
      });
    }
  }
  //---------------------END------------------------//

  //------functions for sending image message  to reciever-------//

  void sendFileMessage(File file, MessageEnum messageEnum) {
    ref
        .read(chatControllerProvider)
        .sendFileMessage(context, file, widget.recieverUserId, messageEnum);
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  //--------------------END -------------------//

  //------functions for sending video message to reciever and also to firebase-------//

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  //--------------------END -------------------//

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
    soundRecorder!.closeRecorder();
    isRecordInit = false;
  }

  void cancelReply() {
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);

    final isShownMessageReply = messageReply != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // isShownMessageReply ? const MessageReplyPreview() : const SizedBox(),
        Row(
          children: [
            Expanded(
              child: Container(
                height: isShownMessageReply ? 120 : 50,
                decoration: BoxDecoration(
                    color: mobileChatBoxColor,
                    borderRadius: isShownMessageReply
                        ? const BorderRadius.all(Radius.circular(15))
                        : const BorderRadius.all(Radius.circular(35))),
                child: Column(
                  children: [
                    isShownMessageReply
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 8, left: 10, right: 10, bottom: 8),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF1E2831),
                                  borderRadius: BorderRadius.circular(10),
                                  border: const BorderDirectional(
                                      start: BorderSide(
                                          color: Colors.green, width: 4))),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        messageReply.isMe ? 'You' : 'Me',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Colors.green.withOpacity(.7),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        messageReply.messageEnum ==
                                                MessageEnum.image
                                            ? 'Photo'
                                            : messageReply.message,
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  messageReply.messageEnum == MessageEnum.image
                                      ? Stack(
                                          alignment: Alignment.centerRight,
                                          children: [
                                            SizedBox(
                                                width: 50,
                                                height: 50,
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      messageReply.message,
                                                  fit: BoxFit.contain,
                                                )),
                                            Positioned(
                                              bottom: 15,
                                              left: 15,
                                              child: IconButton(
                                                  onPressed: () =>
                                                      cancelReply(),
                                                  icon: const Icon(
                                                    Icons.close,
                                                    size: 15,
                                                    color: Colors.black,
                                                  )),
                                            )
                                          ],
                                        )
                                      : IconButton(
                                          onPressed: () => cancelReply(),
                                          icon: const Icon(
                                            Icons.close,
                                            size: 15,
                                            color: Colors.grey,
                                          ))
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(),
                    Flexible(
                      child: TextFormField(
                        onTap: () {
                          hideEmojiContainer();
                          showKeyBoard();
                        },
                        controller: messageController,
                        focusNode: focusNode,
                        onChanged: (value) {
                          setState(() {
                            message = value;
                          });
                        },
                        style: const TextStyle(color: textColor),
                        decoration: InputDecoration(
                            // filled: true,
                            // fillColor: mobileChatBoxColor,
                            hintText: 'Message',
                            hintStyle: const TextStyle(
                                color: kGreyColor, fontSize: 17),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    toggleEmojiKeyboard();
                                  },
                                  icon: Icon(
                                    isEmojiBoxShowing
                                        ? Icons.keyboard
                                        : Icons.emoji_emotions_outlined,
                                    color: kGreyColor,
                                  )),
                            ),
                            suffixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        selectVideo();
                                      },
                                      icon: const Icon(
                                        Icons.attach_file_rounded,
                                        color: kGreyColor,
                                      )),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: kGreyColor),
                                      ),
                                      IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.currency_rupee_sharp,
                                            color: backgroundColor,
                                            size: 15,
                                          )),
                                    ],
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        selectImage();
                                      },
                                      icon: const Icon(
                                        Icons.camera_alt_outlined,
                                        color: kGreyColor,
                                      )),
                                ],
                              ),
                            ),
                            border: InputBorder.none,

                            // border: OutlineInputBorder(
                            //     borderRadius: BorderRadius.circular(35),
                            //     borderSide: const BorderSide(
                            //         width: 0, style: BorderStyle.none)),
                            contentPadding: const EdgeInsets.all(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  sendTextMessage();
                  ref
                      .read(messageReplyProvider.notifier)
                      .update((state) => null);
                  setState(() {
                    message = '';
                  });
                },
                child: CircleAvatar(
                    radius: 20,
                    backgroundColor: floatingActionColor,
                    child: Icon(message.isNotEmpty
                        ? Icons.send
                        : isRecording
                            ? Icons.close
                            : Icons.mic)),
              ),
            )
          ],
        ),
        isEmojiBoxShowing
            ? SizedBox(
                height: MediaQuery.of(context).size.height * .30,
                child: EmojiPicker(
                  onEmojiSelected: ((category, emoji) {
                    setState(() {
                      messageController.text =
                          messageController.text + emoji.emoji;
                      message = emoji.emoji;
                    });
                  }),
                  onBackspacePressed: () {
                    messageController.clear();
                    setState(() {
                      message = '';
                    });
                  },
                  config: const Config(
                      bottomActionBarConfig:
                          BottomActionBarConfig(enabled: false)),
                ),
              )
            : const SizedBox()
      ],
    );
  }
}
