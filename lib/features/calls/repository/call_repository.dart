import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/models/calls.dart';

final callRepositoryProvider = Provider((ref) => CallRepository(
    firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance));

class CallRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CallRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<DocumentSnapshot> get callStream =>
      firestore.collection('calls').doc(auth.currentUser!.uid).snapshots();

  void makeCall(Calls senderCallData, BuildContext context,
      Calls receiverCallData) async {
    try {
      await firestore
          .collection('calls')
          .doc(senderCallData.callerID)
          .set(senderCallData.toMap());

      await firestore
          .collection('calls')
          .doc(receiverCallData.callerID)
          .set(receiverCallData.toMap());
    } catch (e) {
      if (context.mounted) {
        showSnackBAr(context: context, content: e.toString());
      }
    }
  }
}
