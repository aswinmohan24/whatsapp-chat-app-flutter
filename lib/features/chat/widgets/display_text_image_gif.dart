import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/features/chat/widgets/video_player_item.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class DisplayTextImageGIF extends StatelessWidget {
  final String message;
  final MessageEnum type;
  final String messageId;
  final String profilePic;

  const DisplayTextImageGIF(
      {super.key,
      required this.message,
      required this.type,
      required this.messageId,
      required this.profilePic});

  Future<Duration> getAudioMessageDuration(AudioPlayer audioPlayer) async {
    final totalDuration = await audioPlayer.getDuration();
    return totalDuration ?? Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    Duration currentPosition = Duration.zero;
    final AudioPlayer audioPlayer = AudioPlayer();

    return type == MessageEnum.text
        ? Text(
            message,
            style: const TextStyle(fontSize: 16),
          )
        : type == MessageEnum.image
            ? CachedNetworkImage(imageUrl: message)
            : type == MessageEnum.audio
                ? StatefulBuilder(builder: (context, setState) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(right: 10, top: 0, bottom: 0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                CachedNetworkImageProvider(profilePic),
                          ),
                          IconButton(
                            onPressed: () {
                              if (isPlaying) {
                                audioPlayer.pause();
                                setState(() {
                                  isPlaying = false;
                                });
                              } else {
                                audioPlayer.play(UrlSource(message));
                                audioPlayer.volume.floorToDouble();

                                setState(() {
                                  isPlaying = true;
                                });
                              }
                            },
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                              size: 40,
                            ),
                          ),
                          Expanded(
                            child: FutureBuilder<Duration>(
                              future: getAudioMessageDuration(audioPlayer),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const LinearProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return const Text('Error');
                                } else if (snapshot.hasData) {
                                  audioPlayer.onPositionChanged
                                      .listen((Duration p) {
                                    setState(() {
                                      currentPosition = p;
                                    });
                                  });
                                  return ProgressBar(
                                    progress: currentPosition,
                                    total: snapshot.data!,
                                    onSeek: (value) {
                                      audioPlayer.seek(value);
                                    },
                                    onDragStart: (details) {
                                      // Optional: handle on drag start
                                    },
                                    onDragUpdate: (details) {
                                      // Optional: handle on drag update
                                    },
                                    onDragEnd: () {
                                      // Optional: handle on drag end
                                    },
                                    buffered: Duration.zero, // Change as needed
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                : VideoPlayerItemState(videoUrl: message);
  }
}
