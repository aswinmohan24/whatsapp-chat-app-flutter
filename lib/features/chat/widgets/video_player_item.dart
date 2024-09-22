import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/core/colors.dart';

class VideoPlayerItemState extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItemState({super.key, required this.videoUrl});
  @override
  State<VideoPlayerItemState> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItemState> {
  bool isPlaying = false;
  late CachedVideoPlayerController videoPlayerController;
  @override
  void initState() {
    super.initState();
    videoPlayerController = CachedVideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) {
        videoPlayerController.setVolume(1);
      });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          CachedVideoPlayer(videoPlayerController),
          Align(
            alignment: Alignment.center,
            child: IconButton(
                onPressed: () {
                  if (isPlaying) {
                    videoPlayerController.pause();
                  } else {
                    videoPlayerController.play();
                  }
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                },
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_circle,
                  size: 50,
                  color: textColor,
                )),
          )
        ],
      ),
    );
  }
}
