import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/circle_button.dart';
import 'package:modis/components/custom_navigation_bar.dart';
import 'package:modis/components/floating_action_button_modis.dart';
import 'package:modis/components/logo.dart';
import 'package:modis/components/search_input.dart';
import 'package:modis/components/tab_button.dart';
import 'package:modis/pages/create_video.dart';
import 'package:modis/pages/edit_video.dart';
import 'package:modis/pages/play_video.dart';
import 'package:modis/providers/motivation.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';

class Video extends StatefulWidget {
  const Video({super.key});

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  final ScrollController _scrollController = ScrollController(),
      _scrollSingleController = ScrollController();
  String keyword = '';
  final TextEditingController searchController = TextEditingController();
  final FocusNode fSearchController = FocusNode();
  bool _allVideo = true;
  int limit = 10, start = 0, a = 0;
  dynamic categoryId = '';

  @override
  void initState() {
    super.initState();

    getAllVideo();
    _scrollController.addListener(scrollBehavior);
  }

  scrollBehavior() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        start += 10;
      });
      if (_allVideo) {
        getAllVideo();
      } else {
        getVideoBasedGuide();
      }
    }
  }

  getAllVideo() {
    Provider.of<MotivationVideo>(context, listen: false)
        .getAllVideo(limit, start, categoryId, keyword)
        .then((response) {
      if (response['status'] == 'error') {
        snackbarMessenger(context, MediaQuery.of(context).size.width * 0.4,
            Colors.red, 'Gagal terhubung ke server', null);
      }
    }).catchError((error) {
      snackbarMessenger(context, MediaQuery.of(context).size.width * 0.4,
          Colors.red, 'Gagal terhubung ke server', null);
    });
  }

  getVideoBasedGuide() {
    Provider.of<MotivationVideo>(context, listen: false)
        .getVideoBasedGuide(limit, start, categoryId, keyword)
        .then((response) {
      if (response['status'] == 'error') {
        snackbarMessenger(
            context,
            MediaQuery.of(context).size.width * 0.4,
            Colors.red,
            'Gagal terhubung ke server',
            MediaQuery.of(context).size.height * 0.6);
      }
    }).catchError((error) {
      snackbarMessenger(
          context,
          MediaQuery.of(context).size.width * 0.4,
          Colors.red,
          'Gagal terhubung ke server',
          MediaQuery.of(context).size.height * 0.6);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Provider.of<User>(context, listen: false).userRole == 1
          ? ModisAppBar(
              paddingHeader: 3.3,
              title: const Logo(
                fontSize: 26,
                imageSize: 50,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
              action: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications,
                  size: 27,
                  color: Colors.white,
                ),
              ),
              header: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TabButton(
                          isActive: _allVideo,
                          onPressed: () {
                            setState(() {
                              _allVideo = true;
                              start = 0;
                              categoryId = '';
                              keyword = '';
                            });
                            searchController.text = '';
                            fSearchController.unfocus();
                            _scrollController.jumpTo(0.0);
                            getAllVideo();
                            Timer(const Duration(milliseconds: 20), () {
                              _scrollSingleController.jumpTo(0.0);
                            });
                          },
                          label: 'Semua Video',
                        ),
                        TabButton(
                          isActive: !_allVideo,
                          onPressed: () {
                            setState(() {
                              _allVideo = false;
                              start = 0;
                              categoryId = '';
                              keyword = '';
                            });
                            searchController.text = '';
                            fSearchController.unfocus();
                            _scrollController.jumpTo(0.0);
                            getVideoBasedGuide();
                            Timer(const Duration(milliseconds: 20), () {
                              _scrollSingleController.jumpTo(0.0);
                            });
                          },
                          label: 'Video Saya',
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        left: 15.0,
                        right: 15.0,
                      ),
                      child: SearchModis(
                        onSubmitted: (value) {
                          setState(() {
                            keyword = value;
                            start = 0;
                          });
                          if (_allVideo) {
                            getAllVideo();
                          } else {
                            getVideoBasedGuide();
                          }
                        },
                        focusNode: fSearchController,
                        controller: searchController,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ModisAppBar(
              paddingHeader: 2.4,
              title: const Logo(
                fontSize: 26,
                imageSize: 50,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
              action: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications,
                  size: 27,
                  color: Colors.white,
                ),
              ),
              header: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        left: 15.0,
                        right: 15.0,
                      ),
                      child: SearchModis(
                        onSubmitted: (value) {
                          setState(() {
                            keyword = value;
                            start = 0;
                          });
                          getAllVideo();
                        },
                        focusNode: fSearchController,
                        controller: searchController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: Consumer<MotivationVideo>(
        builder: (context, motivation, child) => ListView(
          controller: _scrollController,
          children: motivation.canScroll
              ? motivation.listVideo != null && motivation.listVideo.length != 0
                  ? [
                      motivation.videoCategories != null &&
                              motivation.videoCategories.length != 0
                          ? videoCategory(motivation)
                          : const Text(''),
                      listVideo(motivation),
                      motivation.lengthResponseData >= 10
                          ? loadingContent(0.0)
                          : const Text(''),
                    ]
                  : [
                      motivation.videoCategories != null &&
                              motivation.videoCategories.length != 0
                          ? videoCategory(motivation)
                          : const Text(''),
                      loadingContent(16.0),
                    ]
              : [
                  videoCategory(motivation),
                  motivation.listVideo.length != 0
                      ? listVideo(motivation)
                      : const Padding(
                          padding: EdgeInsets.only(top: 28.0),
                          child: Center(
                            child: Text('Tidak Ada Video'),
                          ),
                        ),
                ],
        ),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: _allVideo
          ? null
          : FloatingActionButtonModis(
              onPressed: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration:
                        const Duration(milliseconds: 300), // Durasi animasi
                    pageBuilder: (BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation) {
                      return const CreateVideo();
                    },
                    transitionsBuilder: (BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                        Widget child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                ).then((value) {
                  if (value == true) {
                    setState(() {
                      start = 0;
                    });
                    getVideoBasedGuide();
                  }
                });
              },
            ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
    );
  }

  Padding loadingContent(double topPadding) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: LoadingIndicator(
              indicatorType: Indicator.ballSpinFadeLoader,
            ),
          ),
          Text(' Loading'),
        ],
      ),
    );
  }

  Column listVideo(MotivationVideo motivation) {
    return Column(
      children: motivation.listVideo
          .map<Widget>(
            (element) => Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
              height: 120,
              child: OutlinedButton(
                onPressed: () {
                  if (_allVideo) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration:
                            const Duration(milliseconds: 300), // Durasi animasi
                        pageBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation) {
                          return VideoPlayerPage(dataVideo: element);
                        },
                        transitionsBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation,
                            Widget child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        surfaceTintColor: Colors.white,
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: 120,
                          child: Row(
                            children: [
                              CircleButtonModis(
                                icon: Icons.edit,
                                label: 'Ubah',
                                colors: const [
                                  Color.fromARGB(255, 162, 111, 0),
                                  Color.fromARGB(255, 255, 202, 87),
                                ],
                                margin: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                  left: 20.0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(
                                          milliseconds: 300), // Durasi animasi
                                      pageBuilder: (BuildContext context,
                                          Animation<double> animation,
                                          Animation<double>
                                              secondaryAnimation) {
                                        return EditVideo(
                                          videoOldData: element,
                                        );
                                      },
                                      transitionsBuilder: (BuildContext context,
                                          Animation<double> animation,
                                          Animation<double> secondaryAnimation,
                                          Widget child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      setState(() {
                                        start = 0;
                                      });
                                      getVideoBasedGuide();
                                    }
                                  });
                                },
                              ),
                              CircleButtonModis(
                                icon: Icons.delete,
                                label: 'Hapus',
                                colors: const [
                                  Color.fromARGB(255, 136, 9, 0),
                                  Color.fromARGB(255, 255, 123, 114),
                                ],
                                margin: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog.adaptive(
                                      backgroundColor: Colors.white,
                                      surfaceTintColor: Colors.white,
                                      title: const Text('Peringatan!!!'),
                                      contentPadding: const EdgeInsets.only(
                                          left: 25.0,
                                          top: 10.0,
                                          bottom: 10.0,
                                          right: 20.0),
                                      actionsPadding: const EdgeInsets.only(
                                        bottom: 20.0,
                                        top: 10.0,
                                      ),
                                      content: const Text(
                                        'Apakah yakin menghapus video?',
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actions: [
                                        FilledButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                              Color.fromRGBO(248, 198, 48, 1),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Batal'),
                                        ),
                                        FilledButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                              Colors.red,
                                            ),
                                          ),
                                          onPressed: () {
                                            loadingIndicator(context);
                                            Provider.of<MotivationVideo>(
                                                    context,
                                                    listen: false)
                                                .deleteVideo(
                                                    element['id'].toString(),
                                                    10,
                                                    0,
                                                    categoryId,
                                                    keyword)
                                                .then(
                                              (response) {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                                if (response['status'] ==
                                                    'success') {
                                                  setState(() {
                                                    start = 0;
                                                  });
                                                  getVideoBasedGuide();
                                                }
                                                snackbarMessenger(
                                                  context,
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  response['status'] ==
                                                          'success'
                                                      ? const Color.fromARGB(
                                                          255, 0, 120, 18)
                                                      : Colors.red,
                                                  response['message'],
                                                  MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.6,
                                                );
                                              },
                                            ).catchError((error) {
                                              snackbarMessenger(
                                                context,
                                                MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                Colors.red,
                                                'Gagal terhubung ke server',
                                                MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.6,
                                              );
                                            });
                                          },
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
                style: const ButtonStyle(
                  padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 8.0)),
                  side: MaterialStatePropertyAll(
                    BorderSide(color: Colors.grey),
                  ),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0.5, -0.5),
                          ),
                        ],
                      ),
                      width: 105,
                      height: 105,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        child: Image.network(
                          'https://modis.techcreator.my.id/${element["thumbnail"]}?timestamp=${DateTime.fromMillisecondsSinceEpoch(100)}',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 13.0),
                      width: MediaQuery.of(context).size.width * 0.87 - 105,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: Text(
                              element['title'],
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            element['name'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  SingleChildScrollView videoCategory(MotivationVideo motivation) {
    return SingleChildScrollView(
      controller: _scrollSingleController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6.0,
            ),
            child: FilledButton(
              onPressed: () {
                setState(() {
                  start = 0;
                  categoryId = '';
                });
                if (_allVideo) {
                  getAllVideo();
                } else {
                  getVideoBasedGuide();
                }
              },
              style: categoryId == ''
                  ? const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                        Color.fromRGBO(248, 198, 48, 1),
                      ),
                    )
                  : const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                        Colors.white,
                      ),
                      side: MaterialStatePropertyAll(
                        BorderSide(
                          color: Color.fromARGB(255, 81, 81, 81),
                        ),
                      ),
                      overlayColor: MaterialStatePropertyAll(
                        Color.fromRGBO(248, 198, 48, 1),
                      ),
                    ),
              child: Text(
                'Semua',
                style: TextStyle(
                  color: categoryId == ''
                      ? Colors.white
                      : const Color.fromARGB(255, 81, 81, 81),
                ),
              ),
            ),
          ),
          Row(
            children: motivation.videoCategories
                .map<Widget>(
                  (element) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          start = 0;
                          categoryId = element['id'];
                        });
                        if (_allVideo) {
                          getAllVideo();
                        } else {
                          getVideoBasedGuide();
                        }
                      },
                      style: categoryId == element['id']
                          ? const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                Color.fromRGBO(248, 198, 48, 1),
                              ),
                            )
                          : const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                Colors.white,
                              ),
                              side: MaterialStatePropertyAll(
                                BorderSide(
                                  color: Color.fromARGB(255, 81, 81, 81),
                                ),
                              ),
                              overlayColor: MaterialStatePropertyAll(
                                Color.fromRGBO(248, 198, 48, 1),
                              ),
                            ),
                      child: Text(
                        element['name'],
                        style: TextStyle(
                          color: categoryId == element['id']
                              ? Colors.white
                              : const Color.fromARGB(255, 81, 81, 81),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
