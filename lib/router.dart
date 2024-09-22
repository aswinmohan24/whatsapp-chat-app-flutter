import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/common/widgets/error.dart';
import 'package:whatsapp_clone/features/auth/screens/login_screen.dart';
import 'package:whatsapp_clone/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_clone/features/auth/screens/user_info_screen.dart';
import 'package:whatsapp_clone/features/select%20contacs/screens/select_contacts_screen.dart';
import 'package:whatsapp_clone/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatsapp_clone/features/status/screens/confirm_status_screen.dart';
import 'package:whatsapp_clone/features/status/screens/status_view_screen.dart';
import 'package:whatsapp_clone/models/status_models.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const LoginScreen()));
    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      return MaterialPageRoute(
          builder: ((context) => OTPScreen(
                verificationId: verificationId,
              )));

    case UserInfoScreen.routeName:
      return MaterialPageRoute(builder: ((context) => const UserInfoScreen()));

    case SelectContactsScreen.routeName:
      return MaterialPageRoute(
          builder: ((context) => const SelectContactsScreen()));
    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      final profilePic = arguments['profilePic'];
      return MaterialPageRoute(
          builder: ((context) => MobileChatScreen(
                name: name,
                uid: uid,
                image: profilePic,
              )));
    case ConfirmStatusScreen.routeName:
      final file = settings.arguments as File;
      return MaterialPageRoute(builder: (ctx) {
        return ConfirmStatusScreen(file: file);
      });
    case StatusViewScreen.routeName:
      final status = settings.arguments as Status;
      return MaterialPageRoute(builder: (ctx) {
        return StatusViewScreen(status: status);
      });
    default:
      return MaterialPageRoute(builder: (ctx) {
        return const Scaffold(
          body: ErrorScreen(error: "The page doesn't exist"),
        );
      });
  }
}
