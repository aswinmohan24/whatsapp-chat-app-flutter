import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libphonenumber/libphonenumber.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/features/chat/screens/mobile_chat_screen.dart';

final selectContactsRepositoryProvider = Provider(
  (ref) =>
      SelectContactsRepository(firebaseFirestore: FirebaseFirestore.instance),
);

class SelectContactsRepository {
  FirebaseFirestore firebaseFirestore;
  SelectContactsRepository({
    required this.firebaseFirestore,
  });

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  void selectContact(BuildContext context, Contact selectedContact) async {
    try {
      final navContext = Navigator.of(context);
      var userCollection = await firebaseFirestore.collection('users').get();

      bool isFound = false;
      String selectedPhoneNumber = selectedContact.phones[0].number;

      // Normalize the selected contact's phone number
      String? normalizedSelectedPhoneNumber =
          await PhoneNumberUtil.normalizePhoneNumber(
        phoneNumber: selectedPhoneNumber,
        isoCode: 'IN', // Replace with your default country code
      );

      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String firebasePhoneNumber = userData.phoneNumber;

        // Normalize the Firebase user's phone number
        String? normalizedFirebasePhoneNumber =
            await PhoneNumberUtil.normalizePhoneNumber(
                phoneNumber: firebasePhoneNumber, isoCode: 'IN');
        debugPrint('firebase $normalizedFirebasePhoneNumber');

        if (normalizedSelectedPhoneNumber == normalizedFirebasePhoneNumber) {
          isFound = true;
          navContext.pushNamed(
            MobileChatScreen.routeName,
            arguments: {
              'name': userData.name,
              'uid': userData.uid,
              'profilePic': userData.profilePic,
            },
          );

          break; // Exit loop once a match is found
        }
      }

      if (!isFound && context.mounted) {
        showSnackBAr(
            context: context,
            content: 'This number does not have a whatsapp account');
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBAr(context: context, content: e.toString());
      }
    }
  }
}
