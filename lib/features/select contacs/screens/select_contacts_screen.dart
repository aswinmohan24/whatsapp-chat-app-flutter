import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/widgets/error.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/features/select%20contacs/controller/select_contact_controller.dart';

class SelectContactsScreen extends ConsumerWidget {
  static const String routeName = '/select-contacs';
  const SelectContactsScreen({super.key});

  selectContact(WidgetRef ref, BuildContext context, Contact selectedContact) {
    ref
        .read(selectContactControllerProvider)
        .selectContacts(context, selectedContact);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select contact'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: ref.watch(getContactProvider).when(
          data: (contactlist) {
            return ListView.builder(
                itemCount: contactlist.length,
                itemBuilder: (context, index) {
                  final contacts = contactlist[index];
                  return InkWell(
                    onTap: () => selectContact(ref, context, contacts),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text(
                          contacts.displayName,
                          style: const TextStyle(fontSize: 20),
                        ),
                        leading: contacts.photo == null
                            ? null
                            : CircleAvatar(
                                radius: 30,
                                backgroundImage: MemoryImage(contacts.photo!)),
                      ),
                    ),
                  );
                });
          },
          error: (err, trace) => ErrorScreen(error: err.toString()),
          loading: () => const Loader()),
    );
  }
}
