import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:whatsapp_clone/core/colors.dart';

ValueNotifier<int> bottomnavIndexNotifier = ValueNotifier(0);

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Color? seletedItemColor = const Color(0xFFD7FDD3);
    return ValueListenableBuilder(
        valueListenable: bottomnavIndexNotifier,
        builder: (context, newIndex, _) {
          return NavigationBarTheme(
            data: const NavigationBarThemeData(
                labelTextStyle: MaterialStatePropertyAll(TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold))),
            child: NavigationBar(
                overlayColor:
                    const MaterialStatePropertyAll(Colors.transparent),
                backgroundColor: backgroundColor,
                indicatorColor: const Color(0xFF0F3629),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (value) {
                  bottomnavIndexNotifier.value = value;
                },
                selectedIndex: newIndex,
                destinations: [
                  NavigationDestination(
                      selectedIcon: Icon(
                        Icons.message_rounded,
                        color: newIndex == 0 ? seletedItemColor : textColor,
                      ),
                      icon: FaIcon(
                        Icons.message_outlined,
                        color: newIndex == 0 ? seletedItemColor : textColor,
                        size: 25,
                      ),
                      label: 'Chats'),
                  NavigationDestination(
                      icon: Icon(
                        Icons.album,
                        color: newIndex == 1 ? seletedItemColor : textColor,
                        size: 25,
                      ),
                      label: 'Updates'),
                  NavigationDestination(
                    selectedIcon: FaIcon(
                      Icons.groups_2,
                      color: newIndex == 2 ? seletedItemColor : textColor,
                    ),
                    icon: FaIcon(
                      Icons.groups_2_outlined,
                      color: newIndex == 2 ? seletedItemColor : textColor,
                      size: 25,
                    ),
                    label: 'Communities',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(
                      Icons.call,
                      color: newIndex == 3 ? seletedItemColor : textColor,
                    ),
                    icon: FaIcon(
                      Icons.call_outlined,
                      color: newIndex == 3 ? seletedItemColor : textColor,
                      size: 25,
                    ),
                    label: 'Calls',
                  )
                ]),
          );
        });
  }
}
