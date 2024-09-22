import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/core/colors.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/select%20contacs/screens/select_contacts_screen.dart';
import 'package:whatsapp_clone/widgets/mobile/appbar_widget.dart';
import 'package:whatsapp_clone/features/chat/widgets/contact_list.dart';

class MobileScreenLayout extends ConsumerStatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  ConsumerState<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends ConsumerState<MobileScreenLayout>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        ref.read(authControllerProvider).setUserState(false);

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(size.height * .15),
            child: const AppBarWidget(
              appBarTitle: 'WhatsApp',
              fontSize: 30,
              fontWeight: FontWeight.w500,
            )),
        body: const Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
              child: SearchBar(
                hintText: 'Search...',
                hintStyle: WidgetStatePropertyAll(TextStyle(color: kGreyColor)),
                backgroundColor: WidgetStatePropertyAll(Color(0xFF242B31)),
                leading: Icon(
                  Icons.search,
                  color: kGreyColor,
                ),
              ),
            ),
            Expanded(child: ContactList()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(SelectContactsScreen.routeName);
          },
          backgroundColor: floatingActionColor,
          child: const Icon(
            Icons.add_comment,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
