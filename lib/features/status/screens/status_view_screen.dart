import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/common/widgets/loader.dart';
import 'package:whatsapp_clone/models/status_models.dart';
import 'package:story_view/story_view.dart';

class StatusViewScreen extends StatefulWidget {
  static const String routeName = '/status-view-screen';
  final Status status;
  const StatusViewScreen({super.key, required this.status});

  @override
  State<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen> {
  StoryController controller = StoryController();
  List<StoryItem> storyItems = [];
  int currentStoryIndex = 0;

  @override
  void initState() {
    super.initState();
    initStoryPageItems();
  }

  void initStoryPageItems() {
    for (int i = 0; i < widget.status.photoUrl.length; i++) {
      storyItems.add(StoryItem.pageImage(
          url: widget.status.photoUrl[i], controller: controller));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = widget.status.createdAt;
    final statusUpdatedTime = DateFormat('hh:mm a').format(dateTime);
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          body: storyItems.isEmpty
              ? const Loader()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                NetworkImage(widget.status.profilePic),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              Text(
                                widget.status.userName,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                statusUpdatedTime,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w400),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: StoryView(
                          inline: true,
                          onStoryShow: (value) {
                            Future.microtask(() {
                              setState(() {
                                currentStoryIndex = storyItems.indexOf(value);
                              });
                            });
                          },
                          storyItems: storyItems,
                          controller: controller,
                          onComplete: () => Navigator.pop(context),
                          onVerticalSwipeComplete: (directions) {
                            if (directions == Direction.down) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.black,
                      width: size.width,
                      height: size.height * .10,
                      child: Text(
                        widget.status.captions[currentStoryIndex],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 19),
                      ),
                    )
                  ],
                )),
    );
  }
}
