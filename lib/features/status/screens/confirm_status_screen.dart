import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/core/colors.dart';
import 'package:whatsapp_clone/features/status/controller/status_controller.dart';

class ConfirmStatusScreen extends ConsumerWidget {
  static const String routeName = '/confirm-status-screen';
  final File file;
  ConfirmStatusScreen({super.key, required this.file});

  void addStatus(WidgetRef ref, BuildContext context, String captions) {
    ref.read(statusControllerProvider).addStatus(file, context, captions);
    Navigator.pop(context);
  }

  final TextEditingController statusCaptionController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String value = '';
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Image.file(file),
        ),
      ),
      floatingActionButton: Row(
        children: [
          const SizedBox(
            width: 15,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              controller: statusCaptionController,
              decoration: const InputDecoration(
                  hintText: 'Add a caption..',
                  fillColor: Colors.black,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)))),
            ),
          )),
          FloatingActionButton(
            onPressed: () {
              final captionText = statusCaptionController.text.trim();
              // Log the current text to see what's being entered
              log('Caption Text: $captionText');
              if (captionText.isNotEmpty) {
                value = captionText;
                // Log the updated list to confirm the text is added
                log('Captions List: $value');
                // Clear the TextField after adding the caption
                statusCaptionController.clear();
                // Call addStatus with the updated list
                addStatus(ref, context, value);
              } else {
                log('Caption is empty, not adding to the list.');
              }
            },
            backgroundColor: floatingActionColor,
            child: const Icon(
              Icons.send,
              color: kBlackColor,
            ),
          ),
        ],
      ),
    );
  }
}
