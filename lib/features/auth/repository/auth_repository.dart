import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/repository/common_firebase_storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/core/constants.dart';
import 'package:whatsapp_clone/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_clone/features/auth/screens/user_info_screen.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/screens/mobile_screen_layout.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firebaseFirestore: FirebaseFirestore.instance));

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firebaseFirestore;

  AuthRepository({required this.auth, required this.firebaseFirestore});

  Future<UserModel?> getCurrentUserData() async {
    final userData = await firebaseFirestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .get();
    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw Exception(e.message);
        },
        codeSent: (String verificationId, int? resendToken) async {
          Navigator.pushNamed(context, OTPScreen.routeName,
              arguments: verificationId);
        },
        codeAutoRetrievalTimeout: ((verificationId) {}),
      );
    } on FirebaseAuthException catch (e) {
      showSnackBAr(context: context, content: e.message!);
    }
  }

  void verifyOTP(
      {required BuildContext context,
      required String verificationID,
      required String userOTP}) async {
    try {
      final navContext = Navigator.of(context);

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationID, smsCode: userOTP);
      await auth.signInWithCredential(credential);
      navContext.pushNamedAndRemoveUntil(
          UserInfoScreen.routeName, (route) => false);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        showSnackBAr(context: context, content: e.message!);
      }
    }
  }

  void saveUserDataToFirebase({
    required String name,
    required File? profilePic,
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        {
          throw Exception('No user found');
        }
      }
      String uid = currentUser.uid;
      String photoUrl = defaultUserInfoImage;
      final navContext = Navigator.of(context);

      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFiletoFirebase('profilePic/$uid', profilePic);
      }
      final user = UserModel(
          name: name,
          uid: uid,
          profilePic: photoUrl,
          isOnline: true,
          phoneNumber: auth.currentUser!.phoneNumber!,
          groupId: []);

      await firebaseFirestore.collection('users').doc(uid).set(user.toMap());
      navContext.pushAndRemoveUntil(MaterialPageRoute(builder: (ctx) {
        return const MobileScreenLayout();
      }), (route) => false);
    } catch (e) {
      if (context.mounted) {
        showSnackBAr(context: context, content: 'hh ${e.toString()}');
      }
    }
  }

  Stream<UserModel> userData(String userId) {
    return firebaseFirestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((event) => UserModel.fromMap(event.data()!));
  }

  void setUserState(bool isOnline) async {
    await firebaseFirestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'isOnline': isOnline});
  }
}
