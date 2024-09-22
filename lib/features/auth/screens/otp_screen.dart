import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';

class OTPScreen extends ConsumerStatefulWidget {
  static const routeName = '/otp-screen';
  final String verificationId;

  const OTPScreen({super.key, required this.verificationId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> with CodeAutoFill {
  String? otpCode = '';
  String? appSignature;

  void verifyOTP(String userOTP) {
    ref
        .read(authControllerProvider)
        .verifyOTP(context, widget.verificationId, userOTP);
  }

  @override
  void codeUpdated() {
    log('OTP code received: $code');
    setState(() {
      otpCode = code;
    });
    if (otpCode != null && otpCode!.length == 6) {
      verifyOTP(otpCode!.trim());
    }
  }

  @override
  void initState() {
    super.initState();
    SmsAutoFill().listenForCode();
    SmsAutoFill().getAppSignature.then((signature) {
      setState(() {
        appSignature = signature;
      });
    });
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your number'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 25),
            const Text('We have sent an SMS with a code'),
            SizedBox(
              width: size.width * 0.5,
              child: PinFieldAutoFill(
                currentCode: otpCode,
                decoration: UnderlineDecoration(
                  textStyle: const TextStyle(fontSize: 20, color: Colors.white),
                  colorBuilder: const FixedColorBuilder(Colors.white),
                ),
                onCodeChanged: (value) {
                  if (value != null && value.length == 6) {
                    setState(() {
                      otpCode = value;
                    });
                    verifyOTP(value.trim());
                  } else {
                    log('Invalid OTP: $value');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// class OTPScreen extends ConsumerWidget {
//   static const routeName = '/otp-screen';
//   final String verificationId;
//   const OTPScreen({super.key, required this.verificationId});

//   void verifyOTP(WidgetRef ref, BuildContext context, String userOTP) {
//     ref
//         .read(authControllerProvider)
//         .verifyOTP(context, verificationId, userOTP);
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Verify your number',
//         ),
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             const SizedBox(height: 25),
//             const Text('We have sent an SMS with a code'),
//             SizedBox(
//                 width: size.width * 0.5,
//                 child: PinFieldAutoFill(
//                   decoration: UnderlineDecoration(
//                     textStyle:
//                         const TextStyle(fontSize: 20, color: Colors.white),
//                     colorBuilder: const FixedColorBuilder(Colors.white),
//                   ),
//                   onCodeChanged: (p0) {},
//                 )

//                 // TextField(
//                 //   textAlign: TextAlign.center,
//                 //   keyboardType: TextInputType.number,
//                 //   decoration: const InputDecoration(
//                 //     hintText: '_ _ _ _ _ _',
//                 //     hintStyle: TextStyle(fontSize: 30),
//                 //   ),
//                 //   onChanged: (value) {
//                 //     if (value.length == 6) {
//                 //       verifyOTP(ref, context, value.trim());
//                 //     } else {
//                 //       showSnackBAr(context: context, content: 'OTP is incorrect');
//                 //     }
//                 //   },
//                 // ),
//                 )
//           ],
//         ),
//       ),
//     );
//   }
// }
