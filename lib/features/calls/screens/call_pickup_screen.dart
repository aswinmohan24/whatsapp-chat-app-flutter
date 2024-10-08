import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/calls/controller/call_controller.dart';
import 'package:whatsapp_clone/models/calls.dart';

class CallPickUpScreen extends ConsumerStatefulWidget {
  final Widget scaffold;
  const CallPickUpScreen({super.key, required this.scaffold});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CallPickUpScreenState();
}

class _CallPickUpScreenState extends ConsumerState<CallPickUpScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: ref.watch(callControllerProvider).callStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.data() != null) {
            Calls call =
                Calls.fromMap(snapshot.data!.data() as Map<String, dynamic>);
            if (call.hasDialled) {
              return Scaffold(
                body: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Incoming Call',
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          call.callerPic,
                        ),
                        radius: 60,
                      ),
                      const SizedBox(height: 50),
                      Text(
                        call.callerName,
                        style: const TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 75,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.redAccent,
                            child: IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.call_end)),
                          ),
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.green,
                            child: IconButton(
                                onPressed: () {}, icon: const Icon(Icons.call)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            }
          }
          return widget.scaffold;
        });
  }
}
