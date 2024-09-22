import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/calls/screens/call__list_screen.dart';
import 'package:whatsapp_clone/features/community/screens/community_screen.dart';
import 'package:whatsapp_clone/features/status/screens/status_screen.dart';
import 'package:whatsapp_clone/screens/mobile_screen_layout.dart';
import 'package:whatsapp_clone/widgets/mobile/bottom_nav_widget.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen>
    with SingleTickerProviderStateMixin {
  final _pages = [
    const MobileScreenLayout(),
    const StatusScreen(),
    const CommunityScreen(),
    const CallsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swipe left
            bottomnavIndexNotifier.value =
                (bottomnavIndexNotifier.value - 1).clamp(0, _pages.length - 1);
          } else if (details.primaryVelocity! < 0) {
            // Swipe right
            bottomnavIndexNotifier.value =
                (bottomnavIndexNotifier.value + 1).clamp(0, _pages.length - 1);
          }
        },
        child: ValueListenableBuilder(
          valueListenable: bottomnavIndexNotifier,
          builder: (context, index, _) {
            return _pages[index];
          },
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(),
    );
  }
}
