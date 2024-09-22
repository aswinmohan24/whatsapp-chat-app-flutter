// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/calls/repository/call_repository.dart';
import 'package:whatsapp_clone/models/calls.dart';

final callControllerProvider = Provider((ref) {
  final callRepository = ref.read(callRepositoryProvider);
  return CallController(
      ref: ref, auth: FirebaseAuth.instance, callRepository: callRepository);
});

class CallController {
  final ProviderRef ref;
  final FirebaseAuth auth;
  final CallRepository callRepository;
  CallController(
      {required this.ref, required this.auth, required this.callRepository});

  Stream<DocumentSnapshot> get callStream => callRepository.callStream;

  void makeCall(BuildContext context, String receiverName, String receiverId,
      String receiverProfiePic) {
    ref.read(userDataAuthProvider).whenData((value) {
      final callId = const Uuid().v1();
      Calls senderCallData = Calls(
        callerID: auth.currentUser!.uid,
        callerName: value!.name,
        callerPic: value.profilePic,
        receiverId: receiverId,
        receieverName: receiverName,
        receiverPic: receiverProfiePic,
        callId: callId,
        hasDialled: true,
      );
      Calls receiverCallData = Calls(
        callerID: auth.currentUser!.uid,
        callerName: value.name,
        callerPic: value.profilePic,
        receiverId: receiverId,
        receieverName: receiverName,
        receiverPic: receiverProfiePic,
        callId: callId,
        hasDialled: false,
      );

      ref
          .read(callRepositoryProvider)
          .makeCall(senderCallData, context, receiverCallData);
    });
  }
}
