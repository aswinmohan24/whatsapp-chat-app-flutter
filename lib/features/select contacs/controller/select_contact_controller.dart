// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whatsapp_clone/features/select%20contacs/repository/select_contacts_repository.dart';

final getContactProvider = FutureProvider((ref) {
  final selectContactRepository = ref.watch(selectContactsRepositoryProvider);
  return selectContactRepository.getContacts();
});

final selectContactControllerProvider = Provider((ref) {
  final selectContactsRepository = ref.watch(selectContactsRepositoryProvider);
  return SelectContactController(
      ref: ref, selectContactsRepository: selectContactsRepository);
});

class SelectContactController {
  final ProviderRef ref;
  final SelectContactsRepository selectContactsRepository;
  SelectContactController({
    required this.ref,
    required this.selectContactsRepository,
  });

  void selectContacts(BuildContext context, Contact selectedContact) {
    selectContactsRepository.selectContact(context, selectedContact);
  }
}
