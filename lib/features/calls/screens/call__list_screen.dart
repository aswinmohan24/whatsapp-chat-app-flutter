import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/landing/screens/landing_screen.dart';

class CallsScreen extends ConsumerWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_2,
              color: Colors.grey,
              size: 30,
            ),
            Text(
              'Coming Soon',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.watch(authControllerProvider).getUserData().whenComplete(() {
            if (context.mounted) {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                return const LandingScreen();
              }));
            }
          });
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
