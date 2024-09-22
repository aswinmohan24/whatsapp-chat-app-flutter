import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/providers/message_reply_provider.dart';
import 'package:whatsapp_clone/common/repository/common_firebase_storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/models/chat_contact.dart';
import 'package:whatsapp_clone/models/message.dart';
import 'package:whatsapp_clone/models/user_model.dart';

final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(
      auth: FirebaseAuth.instance,
      firebaseFirestore: FirebaseFirestore.instance);
});

class ChatRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firebaseFirestore;

  ChatRepository({
    required this.auth,
    required this.firebaseFirestore,
  });

  Stream<List<ChatContact>> getChatContacts() {
    return firebaseFirestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContact.fromMap(document.data());
        var userData = await firebaseFirestore
            .collection('users')
            .doc(chatContact.contactID)
            .get();
        var user = UserModel.fromMap(userData.data()!);
        contacts.add(ChatContact(
            name: user.name,
            profilePic: user.profilePic,
            contactID: chatContact.contactID,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage));
      }
      return contacts;
    });
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    return firebaseFirestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy('timeSend')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  void _saveDataToContactSubCollection(
      UserModel senderUserData,
      UserModel recieverUserData,
      String text,
      DateTime timeSent,
      String recieverUserId) async {
    final recieverChatContact = ChatContact(
      name: senderUserData.name,
      profilePic: senderUserData.profilePic,
      contactID: senderUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );

    await firebaseFirestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(recieverChatContact.toMap());

    final senderChatContact = ChatContact(
      name: recieverUserData.name,
      profilePic: recieverUserData.profilePic,
      contactID: recieverUserData.uid,
      timeSent: timeSent,
      lastMessage: text,
    );

    await firebaseFirestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .set(senderChatContact.toMap());
  }

  void _saveMessagetoMessageSubCollection({
    required String recieversUserId,
    required String text,
    required String messageId,
    required DateTime timeSent,
    required String senderUserName,
    required String recieverUserName,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUsername,
    required String recieverUsername,
  }) async {
    final message = Message(
        senderId: auth.currentUser!.uid,
        recieverId: recieversUserId,
        text: text,
        type: messageType,
        timeSend: timeSent,
        messageId: messageId,
        isSeen: false,
        repliedMessage: messageReply == null ? '' : messageReply.message,
        repliedTo: messageReply == null
            ? ''
            : messageReply.isMe
                ? senderUserName
                : recieverUserName,
        repliedMessageType:
            messageReply == null ? MessageEnum.text : messageReply.messageEnum);

    await firebaseFirestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieversUserId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    await firebaseFirestore
        .collection('users')
        .doc(recieversUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUserData,
    required MessageReply? messageReply,
  }) async {
    try {
      final messageId = const Uuid().v1();
      final timeSent = DateTime.now();
      UserModel recieverUserData;
      final userDataMap =
          await firebaseFirestore.collection('users').doc(recieverUserId).get();

      recieverUserData = UserModel.fromMap(userDataMap.data()!);

      _saveDataToContactSubCollection(
        senderUserData,
        recieverUserData,
        text,
        timeSent,
        recieverUserId,
      );

      _saveMessagetoMessageSubCollection(
        recieversUserId: recieverUserId,
        text: text,
        messageId: messageId,
        timeSent: timeSent,
        senderUserName: senderUserData.name,
        recieverUserName: recieverUserData.name,
        messageType: MessageEnum.text,
        messageReply: messageReply,
        recieverUsername: recieverUserData.name,
        senderUsername: senderUserData.name,
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBAr(context: context, content: 'this ${e.toString()}');
      }
    }
  }

  void sendFileMessage(
      {required BuildContext context,
      required File file,
      required String recieverUserId,
      required UserModel senderUserData,
      required ProviderRef ref,
      required MessageEnum messageEnum,
      required MessageReply? messageReply}) async {
    var timeSend = DateTime.now();
    var messageId = const Uuid().v1();
    final imageUrl = await ref
        .read(commonFirebaseStorageRepositoryProvider)
        .storeFiletoFirebase(
            'chats/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
            file);

    UserModel recieverUserData;
    var userDataMap =
        await firebaseFirestore.collection('users').doc(recieverUserId).get();
    recieverUserData = UserModel.fromMap(userDataMap.data()!);

    String contactMessage;

    switch (messageEnum) {
      case MessageEnum.image:
        contactMessage = '📷 Photo';
      case MessageEnum.video:
        contactMessage = '🎥 Video';
      case MessageEnum.audio:
        contactMessage = '🎵 Audio';
      case MessageEnum.gif:
        contactMessage = 'GIF';

        break;
      default:
        contactMessage = 'GIF';
    }

    _saveDataToContactSubCollection(
      senderUserData,
      recieverUserData,
      contactMessage,
      timeSend,
      recieverUserId,
    );
    _saveMessagetoMessageSubCollection(
      recieversUserId: recieverUserId,
      text: imageUrl,
      messageId: messageId,
      timeSent: timeSend,
      senderUserName: senderUserData.name,
      recieverUserName: recieverUserData.name,
      messageType: messageEnum,
      messageReply: messageReply,
      recieverUsername: recieverUserData.name,
      senderUsername: senderUserData.name,
    );
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await firebaseFirestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      if (context.mounted) {
        showSnackBAr(context: context, content: e.toString());
      }
    }
  }
}
