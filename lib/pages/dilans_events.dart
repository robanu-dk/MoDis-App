import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/circle_button.dart';
import 'package:modis/components/error.dart';
import 'package:modis/components/floating_action_button_modis.dart';
import 'package:modis/components/search_input.dart';
import 'package:modis/components/tab_button.dart';
import 'package:modis/pages/create_edit_event.dart';
import 'package:modis/providers/events.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DilansEvents extends StatefulWidget {
  const DilansEvents({super.key});

  @override
  State<DilansEvents> createState() => _DilansEventsState();
}

class _DilansEventsState extends State<DilansEvents> {
  bool isManageEvent = false,
      isGuide = false,
      isGetData = true,
      isError = false;
  final TextEditingController search = TextEditingController();
  final FocusNode fSearch = FocusNode();
  String keyword = '';
  Map<String, String> month = {
    '01': 'Januari',
    '02': 'Februari',
    '03': 'Maret',
    '04': 'April',
    '05': 'Mei',
    '06': 'Juni',
    '07': 'Juli',
    '08': 'Agustus',
    '09': 'September',
    '10': 'Oktober',
    '11': 'November',
    '12': 'Desember',
  };

  @override
  void initState() {
    super.initState();
    isGuide = Provider.of<User>(context, listen: false).getUserRole() == 1;
    getAllEvents();
  }

  String convertDateToString(String date) {
    List<String> splitDate = date.split('-');
    return '${splitDate[2]} ${month[splitDate[1]]} ${splitDate[0]}';
  }

  void getAllEvents() {
    setState(() {
      isGetData = true;
      isError = false;
    });

    Provider.of<EventsForDilans>(context, listen: false)
        .getAllEvents(keyword, isManageEvent)
        .then((response) {
      if (response['status'] == 'error') {
        snackbarMessenger(
          context,
          MediaQuery.of(context).size.width * 0.5,
          Colors.red,
          'Gagal terhubung ke server',
          MediaQuery.of(context).size.height * 0.6,
        );

        setState(() {
          isError = true;
        });
      } else {
        setState(() {
          isGetData = false;
        });
      }
    }).catchError((error) {
      snackbarMessenger(
        context,
        MediaQuery.of(context).size.width * 0.5,
        Colors.red,
        'Gagal terhubung ke server',
        MediaQuery.of(context).size.height * 0.6,
      );

      setState(() {
        isError = true;
      });
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
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.keyboard_backspace_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const Text(
              'Events For DILANS',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        header: isGuide
            ? Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TabButton(
                          isActive: !isManageEvent,
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            setState(() {
                              isManageEvent = false;
                              keyword = '';
                              isGetData = true;
                            });
                            search.text = '';
                            getAllEvents();
                            fSearch.unfocus();
                          },
                          label: 'Semua Event',
                        ),
                        TabButton(
                          isActive: isManageEvent,
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            setState(() {
                              isManageEvent = true;
                              keyword = '';
                              isGetData = true;
                            });
                            search.text = '';
                            getAllEvents();
                            fSearch.unfocus();
                          },
                          label: 'Kelola Event',
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 8.0),
                      child: SearchModis(
                        onSubmitted: (value) {
                          setState(() {
                            keyword = value;
                            isGetData = true;
                          });
                          getAllEvents();
                        },
                        controller: search,
                        focusNode: fSearch,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                margin:
                    const EdgeInsets.only(left: 12.0, right: 12.0, top: 10.0),
                child: SearchModis(
                  onSubmitted: (value) {
                    setState(() {
                      keyword = value;
                      isGetData = true;
                    });
                    getAllEvents();
                  },
                  controller: search,
                  focusNode: fSearch,
                ),
              ),
        paddingHeader: isGuide ? 3.3 : 2.3,
      ),
      body: isError
          ? ListView(
              children: [
                ServerErrorWidget(
                  onPressed: () {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    getAllEvents();
                  },
                  paddingTop: MediaQuery.of(context).size.height * 0.15,
                  label: 'Gagal memuat informasi Event for DILANS!!!',
                )
              ],
            )
          : isGetData
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballSpinFadeLoader,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text('Loading...'),
                    ),
                  ],
                )
              : Consumer<EventsForDilans>(
                  builder: (context, events, child) => events.listEvent ==
                              null ||
                          events.listEvent.length == 0
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                                child: Text(
                              'Event tidak ditemukan',
                            ))
                          ],
                        )
                      : ListView(
                          children: events.listEvent
                              .map<Widget>((event) => Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                        vertical: 2.0),
                                    child: IconButton(
                                        style: const ButtonStyle(
                                            padding: MaterialStatePropertyAll(
                                                EdgeInsets.zero)),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .removeCurrentSnackBar();
                                          if (isManageEvent &&
                                              DateTime.parse(event['date'])
                                                  .isAfter(DateTime.now())) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => Dialog(
                                                surfaceTintColor: Colors.white,
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: SizedBox(
                                                  height: 120,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircleButtonModis(
                                                        icon: Icons.edit,
                                                        label: 'Ubah',
                                                        colors: const [
                                                          Color.fromARGB(
                                                              255, 162, 111, 0),
                                                          Color.fromARGB(255,
                                                              255, 202, 87),
                                                        ],
                                                        margin: const EdgeInsets
                                                            .only(
                                                          top: 8.0,
                                                          bottom: 8.0,
                                                          left: 20.0,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            PageRouteBuilder(
                                                              transitionDuration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300), // Durasi animasi
                                                              pageBuilder: (BuildContext
                                                                      context,
                                                                  Animation<
                                                                          double>
                                                                      animation,
                                                                  Animation<
                                                                          double>
                                                                      secondaryAnimation) {
                                                                return CreateEditEvent(
                                                                  data: event,
                                                                );
                                                              },
                                                              transitionsBuilder: (BuildContext
                                                                      context,
                                                                  Animation<
                                                                          double>
                                                                      animation,
                                                                  Animation<
                                                                          double>
                                                                      secondaryAnimation,
                                                                  Widget
                                                                      child) {
                                                                return FadeTransition(
                                                                  opacity:
                                                                      animation,
                                                                  child: child,
                                                                );
                                                              },
                                                            ),
                                                          ).then((value) {
                                                            Navigator.pop(
                                                                context);
                                                            if (value) {
                                                              setState(() {
                                                                keyword = '';
                                                                isGetData =
                                                                    true;
                                                              });
                                                              search.text = '';
                                                              getAllEvents();
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      CircleButtonModis(
                                                        icon: Icons.delete,
                                                        label: 'Hapus',
                                                        colors: const [
                                                          Color.fromARGB(
                                                              255, 136, 9, 0),
                                                          Color.fromARGB(255,
                                                              255, 123, 114),
                                                        ],
                                                        margin: const EdgeInsets
                                                            .only(
                                                          top: 8.0,
                                                          bottom: 8.0,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                AlertDialog
                                                                    .adaptive(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              surfaceTintColor:
                                                                  Colors.white,
                                                              title: const Text(
                                                                  'Peringatan!!!'),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          25.0,
                                                                      top: 10.0,
                                                                      bottom:
                                                                          10.0,
                                                                      right:
                                                                          20.0),
                                                              actionsPadding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                bottom: 20.0,
                                                                top: 10.0,
                                                              ),
                                                              content:
                                                                  const Text(
                                                                'Apakah yakin menghapus event?',
                                                              ),
                                                              actionsAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              actions: [
                                                                FilledButton(
                                                                  style:
                                                                      const ButtonStyle(
                                                                    backgroundColor:
                                                                        MaterialStatePropertyAll(
                                                                      Color.fromRGBO(
                                                                          248,
                                                                          198,
                                                                          48,
                                                                          1),
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Text(
                                                                      'Batal'),
                                                                ),
                                                                FilledButton(
                                                                  style:
                                                                      const ButtonStyle(
                                                                    backgroundColor:
                                                                        MaterialStatePropertyAll(
                                                                      Colors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    Provider.of<EventsForDilans>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .deleteEvent(event[
                                                                            'id'])
                                                                        .then(
                                                                            (response) {
                                                                      Navigator.pop(
                                                                          context);
                                                                      if (response[
                                                                              'status'] ==
                                                                          'success') {
                                                                        setState(
                                                                            () {
                                                                          isGetData =
                                                                              true;
                                                                        });
                                                                        getAllEvents();
                                                                        snackbarMessenger(
                                                                          context,
                                                                          MediaQuery.of(context).size.width *
                                                                              0.5,
                                                                          const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              0,
                                                                              120,
                                                                              18),
                                                                          'Berhasil menghapus event',
                                                                          MediaQuery.of(context).size.height *
                                                                              0.6,
                                                                        );
                                                                      } else {
                                                                        snackbarMessenger(
                                                                          context,
                                                                          MediaQuery.of(context).size.width *
                                                                              0.5,
                                                                          Colors
                                                                              .red,
                                                                          '${response["message"]}',
                                                                          MediaQuery.of(context).size.height *
                                                                              0.6,
                                                                        );
                                                                      }
                                                                    }).catchError(
                                                                            (error) {
                                                                      Navigator.pop(
                                                                          context);
                                                                      snackbarMessenger(
                                                                        context,
                                                                        MediaQuery.of(context).size.width *
                                                                            0.5,
                                                                        Colors
                                                                            .red,
                                                                        'Gagal terhubung ke server',
                                                                        MediaQuery.of(context).size.height *
                                                                            0.6,
                                                                      );
                                                                    });
                                                                  },
                                                                  child: const Text(
                                                                      'Hapus'),
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
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (cpntext) => AlertDialog(
                                                backgroundColor: Colors.white,
                                                surfaceTintColor: Colors.white,
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      'Informasi Event',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      icon: const Icon(
                                                          Ionicons.md_close),
                                                    )
                                                  ],
                                                ),
                                                scrollable: true,
                                                content: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    event['poster'] != null
                                                        ? InkWell(
                                                            onTap: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        Dialog(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  child:
                                                                      FractionallySizedBox(
                                                                    widthFactor:
                                                                        1.25,
                                                                    heightFactor:
                                                                        2.0,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          InteractiveViewer(
                                                                        minScale:
                                                                            0.5,
                                                                        maxScale:
                                                                            4.0,
                                                                        child: Image
                                                                            .network(
                                                                          'https://modis.techcreator.my.id/${event["poster"]}?timestamp=${DateTime.fromMillisecondsSinceEpoch(100)}',
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child:
                                                                Image.network(
                                                              'https://modis.techcreator.my.id/${event["poster"]}?timestamp=${DateTime.fromMillisecondsSinceEpoch(100)}',
                                                            ),
                                                          )
                                                        : Container(),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                        event['name'],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16.0),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                          'Tanggal: ${convertDateToString(event["date"])}'),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                        'Waktu: ${event["start_time"].toString().split(":")[0]}:${event["start_time"].toString().split(":")[1]} - ${event["end_time"].toString().split(":")[0]}:${event["end_time"].toString().split(":")[1]}',
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                          'Jenis Event: ${event["type"]}'),
                                                    ),
                                                    event['type'] != 'Online'
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 8.0),
                                                            child: Text(
                                                                'Lokasi: ${event["location"]}'),
                                                          )
                                                        : Container(),
                                                    event['type'] != 'Online'
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 4.0),
                                                            child: FilledButton(
                                                              onPressed:
                                                                  () async {
                                                                Uri url =
                                                                    Uri.parse(
                                                                  event[
                                                                      'coordinate_location'],
                                                                );

                                                                if (await canLaunchUrl(
                                                                    url)) {
                                                                  await launchUrl(
                                                                      url);
                                                                } else {
                                                                  Navigator.pop(
                                                                      context);
                                                                  snackbarMessenger(
                                                                    context,
                                                                    MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.5,
                                                                    Colors.red,
                                                                    'Tidak bisa mengakses lokasi',
                                                                    MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.6,
                                                                  );
                                                                }
                                                              },
                                                              style:
                                                                  ButtonStyle(
                                                                backgroundColor:
                                                                    const MaterialStatePropertyAll(
                                                                        Color.fromARGB(
                                                                            255,
                                                                            1,
                                                                            108,
                                                                            195)),
                                                                shape:
                                                                    MaterialStatePropertyAll(
                                                                  RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                  ),
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                'Lihat Lokasi',
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                          'PIC: ${event["pic_name"]}'),
                                                    ),
                                                  ],
                                                ),
                                                actionsAlignment:
                                                    MainAxisAlignment.center,
                                                actions: DateTime.parse(
                                                            '${event["date"]} ${event["start_time"]}')
                                                        .isAfter(DateTime.now())
                                                    ? [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: FilledButton(
                                                            onPressed:
                                                                () async {
                                                              if (event['contact_person']
                                                                      .toString()
                                                                      .length >
                                                                  9) {
                                                                String phone = event['contact_person'].toString()[
                                                                            0] ==
                                                                        '0'
                                                                    ? event['contact_person']
                                                                        .toString()
                                                                        .replaceFirst(
                                                                            '0',
                                                                            '62')
                                                                    : (event['contact_person'].toString()[0] ==
                                                                            '8'
                                                                        ? '62${event["contact_person"]}'
                                                                        : event[
                                                                            'contact_person']);
                                                                String
                                                                    templateChat =
                                                                    'Selamat ${DateTime.now().hour < 12 ? "pagi" : (DateTime.now().hour < 18 ? "Siang" : "Malam")},%0A%0APerkenalkan saya,%0ANama Lengkap:%0A%0ASaya ingin mengikuti kegiatan "${event["name"]}". Terima kasih';
                                                                Uri url =
                                                                    Uri.parse(
                                                                  'https://api.whatsapp.com/send/?phone=$phone&text=$templateChat',
                                                                );

                                                                await launchUrl(
                                                                    url);
                                                              } else {
                                                                Navigator.pop(
                                                                    context);
                                                                snackbarMessenger(
                                                                  context,
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.5,
                                                                  Colors.red,
                                                                  'Tidak bisa mendaftar',
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.6,
                                                                );
                                                              }
                                                            },
                                                            style:
                                                                const ButtonStyle(
                                                                    backgroundColor:
                                                                        MaterialStatePropertyAll(
                                                              Color.fromRGBO(1,
                                                                  98, 104, 1.0),
                                                            )),
                                                            child: const Text(
                                                                'Daftar'),
                                                          ),
                                                        ),
                                                      ]
                                                    : [],
                                              ),
                                            );
                                          }
                                        },
                                        icon: Card(
                                          surfaceTintColor: Colors.white,
                                          color: Colors.white,
                                          shadowColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 12.0),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: Text(
                                                    event['name'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Text(
                                                  'Tanggal pelaksanaan : ${convertDateToString(event["date"])}',
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ))
                              .toList()),
                ),
      floatingActionButton: isManageEvent
          ? FloatingActionButtonModis(onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration:
                      const Duration(milliseconds: 300), // Durasi animasi
                  pageBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation) {
                    return const CreateEditEvent();
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
                if (value) {
                  getAllEvents();
                }
              });
            })
          : const SizedBox(
              height: 100,
              width: 100,
            ),
      backgroundColor: Colors.white,
    );
  }
}
