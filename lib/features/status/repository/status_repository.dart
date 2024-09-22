import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/common/repository/common_firebase_storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/models/status_models.dart';
import 'package:whatsapp_clone/models/user_model.dart';

final statusRepositoryProvider = Provider(
  (ref) => StatusRepository(
      firebaseFirestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
      ref: ref),
);

class StatusRepository {
  final FirebaseFirestore firebaseFirestore;
  final FirebaseAuth auth;
  final ProviderRef ref;
  StatusRepository({
    required this.firebaseFirestore,
    required this.auth,
    required this.ref,
  });

  void uploadStatus(
      {required String userName,
      required String profilePic,
      required String phoneNumber,
      required File statusImage,
      required String captions,
      required BuildContext context}) async {
    try {
      final statusId = const Uuid().v1();
      final uid = auth.currentUser!.uid;

      String imageUrl = await ref
          .read(commonFirebaseStorageRepositoryProvider)
          .storeFiletoFirebase('/status/$uid/$statusId/', statusImage);
      List<Contact> contacts = [];

      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      List<String> uidWhoCanSee = [];

      for (int i = 0; i < contacts.length; i++) {
        try {
          if (contacts[i].phones.isEmpty) {
            log('Contact ${contacts[i].displayName} has no phone number.');
            continue;
          }

          var userDataFirebase = await firebaseFirestore
              .collection('users')
              .where('phoneNumber',
                  isEqualTo: contacts[i]
                      .phones[0]
                      .normalizedNumber
                      .replaceAll(' ', ''))
              .get();

          if (userDataFirebase.docs.isNotEmpty) {
            var userData = UserModel.fromMap(userDataFirebase.docs[0].data());
            uidWhoCanSee.add(userData.uid);
            log('Added user: ${userData.name}');
          }
        }
        //   else {
        //     log(
        //         'No matching user found for ${contacts[i].phones[0].normalizedNumber}');
        //   }
        // }
        catch (e) {
          log('Error in processing contact ${contacts[i].displayName}: $e');
        }
      }

      List<String> statusImageUrl = [];
      List<String> allCaptions = [];
      var statusesSnaspshot = await firebaseFirestore
          .collection('status')
          .where(
            'uid',
            isEqualTo: auth.currentUser!.uid,
          )
          .get();

      if (statusesSnaspshot.docs.isNotEmpty) {
        Status status = Status.fromMap(statusesSnaspshot.docs[0].data());
        statusImageUrl = status.photoUrl;
        statusImageUrl.add(imageUrl);
        allCaptions = status.captions;
        allCaptions.add(captions);
        await firebaseFirestore
            .collection('status')
            .doc(statusesSnaspshot.docs[0].id)
            .update({'photoUrl': statusImageUrl, 'captions': allCaptions});
        return;
      } else {
        statusImageUrl = [imageUrl];
        allCaptions = [captions];
      }
      Status status = Status(
          uid: uid,
          userName: userName,
          phoneNumber: phoneNumber,
          photoUrl: statusImageUrl,
          captions: allCaptions,
          createdAt: DateTime.now(),
          profilePic: profilePic,
          statusId: statusId,
          whoCanSee: uidWhoCanSee);

      log('this is my $status');

      await firebaseFirestore
          .collection('status')
          .doc(statusId)
          .set(status.toMap());
    } on FirebaseException catch (e) {
      log(e.toString());
    } catch (e) {
      if (context.mounted) {
        showSnackBAr(context: context, content: e.toString());
      }
    }
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statusData = [];
    try {
      List<Contact> contacts = [];

      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }

      // Query statuses for contacts
      for (int i = 0; i < contacts.length; i++) {
        if (contacts[i].phones.isNotEmpty) {
          var statusSnapshot = await firebaseFirestore
              .collection('status')
              .where('phoneNumber',
                  isEqualTo: contacts[i]
                      .phones[0]
                      .normalizedNumber
                      .replaceAll(' ', ''))
              .where('createdAt',
                  isGreaterThan: DateTime.now()
                      .subtract(const Duration(hours: 24))
                      .millisecondsSinceEpoch)
              .get();

          for (var tempData in statusSnapshot.docs) {
            log('Fetching others status');
            Status status = Status.fromMap(tempData.data());
            if (status.whoCanSee.contains(auth.currentUser!.uid)) {
              statusData.add(status);
            }
          }
        }
      }

      // Query statuses for your own phone number
      var myStatusSnapshot = await firebaseFirestore
          .collection('status')
          .where('phoneNumber', isEqualTo: auth.currentUser!.phoneNumber)
          .where('createdAt',
              isGreaterThan: DateTime.now()
                  .subtract(const Duration(hours: 24))
                  .millisecondsSinceEpoch)
          .get();

      for (var tempData in myStatusSnapshot.docs) {
        Status status = Status.fromMap(tempData.data());
        log('Fetched  my status');

        statusData.add(status);
      }
    } catch (e) {
      log(e.toString());
      if (context.mounted) {
        showSnackBAr(context: context, content: e.toString());
      }
    }
    log(statusData.toString());
    return statusData;
  }
}
