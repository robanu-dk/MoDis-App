import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/input_implement.dart';
import 'package:modis/providers/motivation.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CreateVideo extends StatefulWidget {
  const CreateVideo({super.key});

  @override
  State<CreateVideo> createState() => _CreateVideoState();
}

class _CreateVideoState extends State<CreateVideo> {
  final ImagePicker _pickerImage = ImagePicker(), _pickVideo = ImagePicker();
  final TextEditingController title = TextEditingController(),
      description = TextEditingController();
  int? category;
  bool showPreviewThumbnail = false, showPreviewVideo = false;
  File? thumbnail, video;
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    if (Provider.of<MotivationVideo>(context, listen: false).videoCategories ==
        null) {
      Provider.of<MotivationVideo>(context, listen: false).getCategories();
    }
  }

  void snackbarMessenger(BuildContext context, double leftPadding,
      Color backgroundColor, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: leftPadding,
          right: 9,
          bottom: MediaQuery.of(context).size.height * 0.72,
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

  void loadingIndicator(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(154, 0, 0, 0),
          insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.3),
          content: const LoadingIndicator(
            indicatorType: Indicator.ballSpinFadeLoader,
            colors: [Colors.white],
          ),
        ),
      ),
    );
  }

  Future<void> loadVideo() async {
    try {
      videoPlayerController = VideoPlayerController.file(video!);

      await Future.wait([videoPlayerController.initialize()]);

      setState(() {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: false,
          allowedScreenSleep: false,
          allowFullScreen: true,
          looping: false,
        );
      });
    } catch (error) {
      // snackbarMessenger(
      //   context,
      //   MediaQuery.of(context).size.width * 0.5,
      //   Colors.red,
      //   'Gagal memutar video',
      //   MediaQuery.of(context).size.height * 0.6,
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              'Buat Video',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        paddingHeader: 1.5,
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Input(
              textController: title,
              label: 'Judul',
              border: const OutlineInputBorder(),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            margin: const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0),
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              border: Border.all(
                strokeAlign: BorderSide.strokeAlignInside,
                color: Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Consumer<MotivationVideo>(
              builder: (context, video, child) => DropdownButtonFormField(
                decoration: const InputDecoration(border: InputBorder.none),
                value: category,
                hint: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.grid_view_outlined,
                        color: Color.fromRGBO(120, 120, 120, 1),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text('Pilih Kategori Video'),
                    ),
                  ],
                ),
                items: video.videoCategories
                    .map<DropdownMenuItem<int>>(
                      (element) => DropdownMenuItem<int>(
                        value: element['id'],
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.grid_view_outlined,
                                color: Color.fromRGBO(120, 120, 120, 1),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Text(
                                element['name'],
                                style: const TextStyle(
                                  color: Color.fromRGBO(120, 120, 120, 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  category = value;
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Input(
              textController: description,
              label: 'Deskripsi',
              border: const OutlineInputBorder(),
              maxLines: null,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
            child: OutlinedButton(
              onPressed: () {
                _pickerImage
                    .pickImage(source: ImageSource.gallery)
                    .then((value) {
                  setState(() {
                    thumbnail = File(value!.path);
                    showPreviewThumbnail = true;
                  });
                });
              },
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(6.0),
                    ),
                  ),
                ),
                padding: MaterialStatePropertyAll(
                  EdgeInsets.only(left: 10.0),
                ),
              ),
              child: const SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      color: Color.fromRGBO(120, 120, 120, 1),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Unggah Thumbnail',
                        style: TextStyle(
                          color: Color.fromRGBO(120, 120, 120, 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          showPreviewThumbnail
              ? Container(
                  margin:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preview:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.file(thumbnail!),
                    ],
                  ),
                )
              : Container(),
          Container(
            margin: const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
            child: OutlinedButton(
              onPressed: () {
                _pickVideo.pickVideo(source: ImageSource.gallery).then((value) {
                  setState(() {
                    showPreviewVideo = true;
                    video = File(value!.path);
                    loadVideo();
                  });
                });
              },
              style: const ButtonStyle(
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(6.0),
                    ),
                  ),
                ),
                padding: MaterialStatePropertyAll(
                  EdgeInsets.only(left: 10.0),
                ),
              ),
              child: const SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      color: Color.fromRGBO(120, 120, 120, 1),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Unggah Video',
                        style: TextStyle(
                          color: Color.fromRGBO(120, 120, 120, 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          showPreviewVideo
              ? Container(
                  margin:
                      const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preview:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      chewieController != null &&
                              chewieController!
                                  .videoPlayerController.value.isInitialized
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 235,
                              child: Chewie(controller: chewieController!),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.ballSpinFadeLoader,
                                  ),
                                ),
                                Text('loading'),
                              ],
                            ),
                    ],
                  ),
                )
              : Container(),
          Container(
            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: FilledButton(
              onPressed: () {
                if (title.text != '' &&
                    category != null &&
                    showPreviewThumbnail &&
                    showPreviewVideo) {
                  loadingIndicator(context);
                  Provider.of<MotivationVideo>(context, listen: false)
                      .uploadVideo(
                          title: title.text,
                          category: category!,
                          description: description.text,
                          thumbnail: thumbnail!,
                          video: video!)
                      .then((response) {
                    Navigator.pop(context);
                    if (response['status'] == 'success') {
                      Navigator.pop(context);
                      snackbarMessenger(
                        context,
                        MediaQuery.of(context).size.width * 0.4,
                        const Color.fromARGB(255, 0, 120, 18),
                        'berhasil mengunggah video',
                      );
                    } else {
                      snackbarMessenger(
                        context,
                        MediaQuery.of(context).size.width * 0.4,
                        Colors.red,
                        response['message'],
                      );
                    }
                  }).catchError((error) {
                    Navigator.pop(context);
                    snackbarMessenger(
                      context,
                      MediaQuery.of(context).size.width * 0.4,
                      Colors.red,
                      'Gagal terhubung server',
                    );
                  });
                } else {
                  snackbarMessenger(
                    context,
                    MediaQuery.of(context).size.width * 0.4,
                    Colors.red,
                    'Terdapat data yang belum diisi!!!',
                  );
                }
              },
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Color.fromRGBO(248, 198, 48, 1),
                ),
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
