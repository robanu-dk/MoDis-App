import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

class DetailActivity extends StatefulWidget {
  const DetailActivity({super.key, required this.data});
  final dynamic data;

  @override
  State<DetailActivity> createState() => _DetailActivityState();
}

class _DetailActivityState extends State<DetailActivity> {
  bool start = false;
  int second = 0, minute = 0, hour = 0;
  Timer? duration, tracking;
  MapController mapController = MapController();
  LatLng currentPosition = const LatLng(-6.175392, 106.827183);

  List<Position> position = [];

  String emailFilter = '';

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
    getCurrentPosition();
    setState(() {
      emailFilter = Provider.of<User>(context, listen: false).userEmail;
    });
  }

  Future getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        snackbarMessenger(
          context,
          MediaQuery.of(context).size.width * 0.35,
          Colors.red,
          'gagal memberikan izin mengakses lokasi',
          MediaQuery.of(context).size.height * 0.6,
        );
        Navigator.pop(context);
      }
      Position pos = await Geolocator.getCurrentPosition();
      setState(() {
        currentPosition = LatLng(pos.latitude, pos.longitude);
      });
      mapController.move(currentPosition, 15.0);
    } else {
      Position pos = await Geolocator.getCurrentPosition();
      setState(() {
        currentPosition = LatLng(pos.latitude, pos.longitude);
      });
      mapController.move(currentPosition, 15.0);
    }
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

  filterParticipantStatus(dynamic data, bool isDone) {
    String guideEmail = Provider.of<User>(context, listen: false).userEmail;

    if (isDone) {
      return data
          .where((element) =>
              int.parse(element['done'].toString()) == 1 &&
              element['email'] != guideEmail)
          .toList();
    } else {
      return data
          .where((element) =>
              int.parse(element['done'].toString()) == 0 &&
              element['email'] != guideEmail)
          .toList();
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  convertDateToString(String date) {
    List<String> splitDate = date.split(' ')[0].split('-');

    return '${splitDate[2]} ${month[splitDate[1]]} ${splitDate[0]}';
  }

  handleTime(String time) {
    List<String> splitTime = time.split(':');

    return '${splitTime[0]}:${splitTime[1]}';
  }

  filter(dynamic data, String email) {
    if (email != '') {
      return data.where((element) => element['email'] == email).toList()[0];
    }

    return data[0];
  }

  Container rowInformation(BuildContext context, String label,
      String information, double paddingTop) {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05,
        top: paddingTop,
      ),
      child: Row(
        children: [
          SizedBox(
            width: information != ''
                ? MediaQuery.of(context).size.width * 0.32
                : MediaQuery.of(context).size.width * 0.8,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
            child: const Text(
              ':',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          information != ''
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.53,
                  child: Text(information),
                )
              : Container(),
        ],
      ),
    );
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
                if (!start) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(
                Icons.keyboard_backspace_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const Text(
              'Detail Aktivitas',
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
      body: PopScope(
        canPop: !start,
        child: ListView(
          children: [
            int.parse(filter(widget.data, emailFilter)['created_by_guide']
                            .toString()) ==
                        1 &&
                    (DateTime.now().add(const Duration(minutes: 30)).isAfter(
                            DateTime.parse(
                                '${filter(widget.data, emailFilter)["date"]} ${filter(widget.data, emailFilter)["end_time"]}')) ||
                        int.parse(filter(widget.data, emailFilter)['done']
                                .toString()) ==
                            1)
                ? Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                surfaceTintColor: Colors.white,
                                backgroundColor: Colors.white,
                                titlePadding: const EdgeInsets.only(
                                    left: 20.0, right: 18.0, top: 10.0),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Pilih Akun',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Ionicons.md_close),
                                    ),
                                  ],
                                ),
                                content: SizedBox(
                                  height: widget.data.length * 50 > 300
                                      ? 300
                                      : (widget.data.length == 0
                                          ? 100
                                          : double.parse(
                                              (widget.data.length * 50)
                                                  .toString())),
                                  child: ListView(
                                    children: widget.data
                                        .map<Widget>(
                                          (data) => OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                emailFilter = data['email'];
                                                Navigator.pop(context);
                                              });
                                            },
                                            style: const ButtonStyle(
                                              shape: MaterialStatePropertyAll(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(8.0),
                                                  ),
                                                ),
                                              ),
                                              padding: MaterialStatePropertyAll(
                                                EdgeInsets.symmetric(
                                                    horizontal: 10.0),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  data['user_name'],
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                            );
                          },
                          style: const ButtonStyle(
                            shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            padding: MaterialStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 3.0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.filter_list_outlined,
                                color: Colors.black,
                              ),
                              Text(
                                filter(widget.data, emailFilter)['user_name'],
                                style: const TextStyle(color: Colors.black),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            Text('data ${widget.data}'),
            rowInformation(
              context,
              'Nama Aktivitas',
              filter(widget.data, emailFilter)['name'].toString(),
              25.0,
            ),
            rowInformation(
              context,
              'Waktu Pelaksanaan',
              '${convertDateToString(filter(widget.data, emailFilter)["date"])} (${handleTime(filter(widget.data, emailFilter)["start_time"].toString())} - ${handleTime(filter(widget.data, emailFilter)["end_time"].toString())})',
              15.0,
            ),
            rowInformation(
              context,
              'Keterangan',
              filter(widget.data, emailFilter)['note'] ?? '-',
              15.0,
            ),
            rowInformation(
              context,
              'Waktu Mulai',
              filter(widget.data, emailFilter)['start_activity_time'] ?? '-',
              15.0,
            ),
            rowInformation(
              context,
              'Waktu Selesai',
              filter(widget.data, emailFilter)['finishing_activity_time'] ??
                  '-',
              15.0,
            ),
            rowInformation(
              context,
              'Durasi',
              filter(widget.data, emailFilter)['finishing_activity_time'] ??
                  '-',
              15.0,
            ),
            widget.data.length > 1
                ? Column(
                    children: [
                      rowInformation(
                        context,
                        'Daftar Peserta yang menyelesaikan',
                        '',
                        15.0,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05),
                        child: Column(
                          children: filterParticipantStatus(widget.data, true)
                              .map<Widget>((data) => Text(data['user_name']))
                              .toList(),
                        ),
                      ),
                      rowInformation(
                        context,
                        'Daftar Peserta yang tidak menyelesaikan',
                        '',
                        15.0,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05),
                        child: Column(
                          children: filterParticipantStatus(widget.data, false)
                              .map<Widget>((data) => Text(data['user_name']))
                              .toList(),
                        ),
                      ),
                    ],
                  )
                : Container(),
            rowInformation(
              context,
              'Pergerakan',
              ' ',
              15.0,
            ),
            Container(
              margin: EdgeInsets.only(
                bottom: 40.0,
                top: 8.0,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              height: 400,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: currentPosition,
                  initialZoom: 10.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  )
                ],
              ),
            ),
            int.parse(widget.data[0]['done'].toString()) != 1 &&
                    DateTime.parse(
                            '${widget.data[0]["date"]} ${widget.data[0]["end_time"]}')
                        .isAfter(DateTime.now())
                ? Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.1,
                      right: MediaQuery.of(context).size.width * 0.1,
                      bottom: 30.0,
                    ),
                    child: FilledButton(
                      onPressed: () async {
                        if (await Geolocator.checkPermission() ==
                            LocationPermission.denied) {
                          await Geolocator.requestPermission();
                        } else {
                          // print(
                          //     'cekk ${await Geolocator.getCurrentPosition()}');
                          // print(
                          //     'cekk${Geolocator.distanceBetween(-7.2676037, 112.7796517, -7.2675799, 112.7795996)}');
                          print('cekk$currentPosition');
                          // Timer a =
                          //     Timer.periodic(Duration(seconds: 5), (timer) {
                          //   print('cekk $position');
                          // });
                          // if (!start) {
                          //   setState(() {
                          //     start = true;
                          //   });
                          //   tracking = Timer.periodic(
                          //       const Duration(seconds: 5), (timer) async {
                          //     Position pos =
                          //         await Geolocator.getCurrentPosition();
                          //     setState(() {
                          //       position.add(pos);
                          //     });
                          //   });
                          // } else {
                          //   tracking!.cancel();
                          //   a.cancel();
                          // }

                          // if (start) {
                          //   showDialog(
                          //     context: context,
                          //     builder: (context) => AlertDialog(
                          //       surfaceTintColor: Colors.white,
                          //       backgroundColor: Colors.white,
                          //       titlePadding: const EdgeInsets.only(
                          //         left: 20.0,
                          //         right: 17.0,
                          //         top: 4.0,
                          //       ),
                          //       title: Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           const Text(
                          //             'Peringatan',
                          //             style: TextStyle(
                          //               color: Colors.black,
                          //               fontWeight: FontWeight.bold,
                          //               fontSize: 14.0,
                          //             ),
                          //           ),
                          //           IconButton(
                          //             onPressed: () {
                          //               Navigator.pop(context);
                          //             },
                          //             icon: const Icon(Ionicons.md_close),
                          //           )
                          //         ],
                          //       ),
                          //       content: const Text(
                          //         'Apakah anda yakin menyelesaikan aktivitas?',
                          //       ),
                          //       actions: [
                          //         Row(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           children: [
                          //             Container(
                          //               margin: EdgeInsets.only(
                          //                   right: MediaQuery.of(context)
                          //                           .size
                          //                           .width *
                          //                       0.04),
                          //               child: FilledButton(
                          //                 style: const ButtonStyle(
                          //                   backgroundColor:
                          //                       MaterialStatePropertyAll(
                          //                     Color.fromRGBO(248, 198, 48, 1),
                          //                   ),
                          //                   shape: MaterialStatePropertyAll(
                          //                     RoundedRectangleBorder(
                          //                       borderRadius: BorderRadius.all(
                          //                         Radius.circular(8.0),
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 ),
                          //                 onPressed: () {},
                          //                 child: const Text(
                          //                   'Batal',
                          //                   style: TextStyle(
                          //                     fontWeight: FontWeight.bold,
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //             Container(
                          //               margin: EdgeInsets.only(
                          //                   left: MediaQuery.of(context)
                          //                           .size
                          //                           .width *
                          //                       0.04),
                          //               child: FilledButton(
                          //                 style: const ButtonStyle(
                          //                   backgroundColor:
                          //                       MaterialStatePropertyAll(
                          //                     Color.fromRGBO(1, 98, 104, 1.0),
                          //                   ),
                          //                   shape: MaterialStatePropertyAll(
                          //                     RoundedRectangleBorder(
                          //                       borderRadius: BorderRadius.all(
                          //                         Radius.circular(8.0),
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 ),
                          //                 onPressed: () {
                          //                   setState(() {
                          //                     start = false;
                          //                   });

                          //                   Navigator.pop(context);
                          //                 },
                          //                 child: const Text(
                          //                   'Iya',
                          //                   style: TextStyle(
                          //                     fontWeight: FontWeight.bold,
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ],
                          //     ),
                          //   );
                          // } else {
                          //   showDialog(
                          //     context: context,
                          //     builder: (context) => AlertDialog(
                          //       surfaceTintColor: Colors.white,
                          //       backgroundColor: Colors.white,
                          //       titlePadding: const EdgeInsets.only(
                          //         left: 20.0,
                          //         right: 17.0,
                          //         top: 4.0,
                          //       ),
                          //       title: Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           const Text(
                          //             'Peringatan',
                          //             style: TextStyle(
                          //               color: Colors.black,
                          //               fontWeight: FontWeight.bold,
                          //               fontSize: 14.0,
                          //             ),
                          //           ),
                          //           IconButton(
                          //             onPressed: () {
                          //               Navigator.pop(context);
                          //             },
                          //             icon: const Icon(Ionicons.md_close),
                          //           )
                          //         ],
                          //       ),
                          //       content: const Text(
                          //         'Apakah anda yakin akan memulai aktivitas?',
                          //       ),
                          //       actions: [
                          //         Row(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           children: [
                          //             Container(
                          //               margin: EdgeInsets.only(
                          //                   right: MediaQuery.of(context)
                          //                           .size
                          //                           .width *
                          //                       0.04),
                          //               child: FilledButton(
                          //                 style: const ButtonStyle(
                          //                   backgroundColor:
                          //                       MaterialStatePropertyAll(
                          //                     Color.fromRGBO(248, 198, 48, 1),
                          //                   ),
                          //                   shape: MaterialStatePropertyAll(
                          //                     RoundedRectangleBorder(
                          //                       borderRadius: BorderRadius.all(
                          //                         Radius.circular(8.0),
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 ),
                          //                 onPressed: () {},
                          //                 child: const Text(
                          //                   'Batal',
                          //                   style: TextStyle(
                          //                     fontWeight: FontWeight.bold,
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //             Container(
                          //               margin: EdgeInsets.only(
                          //                   left: MediaQuery.of(context)
                          //                           .size
                          //                           .width *
                          //                       0.04),
                          //               child: FilledButton(
                          //                 style: const ButtonStyle(
                          //                   backgroundColor:
                          //                       MaterialStatePropertyAll(
                          //                     Color.fromRGBO(1, 98, 104, 1.0),
                          //                   ),
                          //                   shape: MaterialStatePropertyAll(
                          //                     RoundedRectangleBorder(
                          //                       borderRadius: BorderRadius.all(
                          //                         Radius.circular(8.0),
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 ),
                          //                 onPressed: () {},
                          //                 child: const Text(
                          //                   'Iya',
                          //                   style: TextStyle(
                          //                     fontWeight: FontWeight.bold,
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ],
                          //     ),
                          //   );
                          // }
                        }
                      },
                      style: ButtonStyle(
                        shape: const MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ),
                        backgroundColor: MaterialStatePropertyAll(
                          start
                              ? const Color.fromRGBO(248, 198, 48, 1)
                              : const Color.fromRGBO(1, 98, 104, 1.0),
                        ),
                      ),
                      child: Text(
                        start ? 'Selesaikan' : 'Mulai',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
