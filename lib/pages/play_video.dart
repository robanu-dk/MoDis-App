import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.dataVideo});

  final dynamic dataVideo;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;
  bool isLoad = true;

  void snackbarMessenger(BuildContext context, double leftPadding,
      Color backgroundColor, String message, double? bottomPadding) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: leftPadding,
          right: 9,
          bottom: bottomPadding ?? MediaQuery.of(context).size.height * 0.75,
        ),
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: const TextStyle(fontSize: 14),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Future<void> loadVideo() async {
    try {
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(
          'https://modis.techcreator.my.id/${widget.dataVideo["video"]}?timestap=${DateTime.fromMillisecondsSinceEpoch(100)}',
        ),
      );

      await Future.wait([videoPlayerController.initialize()]);

      setState(() {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: true,
          allowedScreenSleep: false,
          allowFullScreen: true,
          looping: false,
        );
      });
    } catch (error) {
      snackbarMessenger(
        context,
        MediaQuery.of(context).size.width * 0.5,
        Colors.red,
        'Gagal memutar video',
        MediaQuery.of(context).size.height * 0.6,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    loadVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModisAppBar(
        action: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications,
            size: 27,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.keyboard_backspace_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const Text(
              'Putar Video',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        paddingHeader: 1.0,
        noFreeSpace: true,
      ),
      body: ListView(
        children: [
          chewieController != null &&
                  chewieController!.videoPlayerController.value.isInitialized
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 9 / 16,
                      child: Chewie(controller: chewieController!),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 8.0),
                      child: Text(
                        widget.dataVideo['title'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 10.0),
                      child: Text(widget.dataVideo['description']),
                    )
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.4),
                      height: 30,
                      width: 30,
                      child: const LoadingIndicator(
                        indicatorType: Indicator.ballSpinFadeLoader,
                      ),
                    ),
                    const Text('loading'),
                  ],
                ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
