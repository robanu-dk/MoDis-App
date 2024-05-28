import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/providers/activity.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

class DetailActivity extends StatefulWidget {
  const DetailActivity({super.key, required this.activityId});
  final String activityId;

  @override
  State<DetailActivity> createState() => _DetailActivityState();
}

class _DetailActivityState extends State<DetailActivity> {
  bool start = false, getData = true;
  Timer? duration;
  MapController mapController = MapController();
  LatLng currentPosition = const LatLng(-6.175392, 106.827183);
  List<Position> position = [];
  List<dynamic> participants = [], presentParticipants = [];
  String emailFilter = '', startTime = '', endTime = '';
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
  List data = [];

  @override
  void initState() {
    super.initState();
    Provider.of<Activity>(context, listen: false).resetDuration();
    Provider.of<Activity>(context, listen: false).resetCoordinates();
    getActivityData();
  }

  getActivityData() {
    Provider.of<Activity>(context, listen: false)
        .getDetailActivities(widget.activityId)
        .then((response) {
      if (response['status'] == 'success') {
        setState(() {
          data.addAll(response['data']);
          participants.addAll(response['data']);
          emailFilter = Provider.of<User>(context, listen: false).userEmail;
          getData = false;
        });

        getCurrentPosition();
      } else {
        snackbarMessenger(
          context,
          MediaQuery.of(context).size.width * 0.35,
          Colors.red,
          response['message'],
          MediaQuery.of(context).size.height * 0.6,
        );
      }
    }).catchError((error) {
      snackbarMessenger(
        context,
        MediaQuery.of(context).size.width * 0.35,
        Colors.red,
        'gagal terhubung ke server',
        MediaQuery.of(context).size.height * 0.6,
      );
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

  setCoordinatesData() {
    Provider.of<Activity>(context, listen: false)
        .setCoordinatesData(data, emailFilter)
        .then((coordinates) {
      if (coordinates.isNotEmpty) {
        mapController.move(coordinates[0], 18.0);
      }
    });
  }

  getCurrentPosition() async {
    LatLng currentPosition;
    if (!checkIfDataDone(data) &&
        DateTime.parse('${data[0]["date"]} ${data[0]["end_time"]}')
            .isAfter(DateTime.now())) {
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
        currentPosition = LatLng(pos.latitude, pos.longitude);
        mapController.move(currentPosition, 18.0);
      } else {
        Position pos = await Geolocator.getCurrentPosition();

        currentPosition = LatLng(pos.latitude, pos.longitude);
        mapController.move(currentPosition, 18.0);
      }
    } else {
      setCoordinatesData();
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

  checkIfDataDone(List data) {
    bool isDone = false;

    for (var item in data) {
      if (int.parse(item['done'].toString()) == 1 &&
          item['email'] ==
              Provider.of<User>(context, listen: false).userEmail) {
        isDone = true;
        break;
      }
    }

    return isDone;
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
    setCoordinatesData();

    if (email != '') {
      return data.where((element) => element['email'] == email).toList()[0];
    }

    return data[0];
  }

  countingDuration() {
    setState(() {
      duration = Timer.periodic(const Duration(seconds: 1), (timer) {
        bool updateTracking =
            Provider.of<Activity>(context, listen: false).countingDuration();

        if (updateTracking) {
          List coordinates =
              Provider.of<Activity>(context, listen: false).coordinates;
          mapController.move(coordinates[coordinates.length - 1], 18.0);
        }

        if (DateTime.now().isAfter(
            DateTime.parse('${data[0]["date"]} ${data[0]["end_time"]}')
                .add(const Duration(minutes: 30)))) {
          loadingIndicator(context);
          Provider.of<Activity>(context, listen: false)
              .finishActivity(
            data[0]['id'].toString(),
            startTime,
            endTime,
            Provider.of<Activity>(context, listen: false).coordinates,
            presentParticipants,
          )
              .then((response) {
            Navigator.pop(context);
            if (response['status'] == 'success') {
              Navigator.pop(context, true);

              snackbarMessenger(
                context,
                MediaQuery.of(context).size.width * 0.35,
                const Color.fromARGB(255, 0, 120, 18),
                'berhasil menyelesaikan kegiatan',
                MediaQuery.of(context).size.height * 0.6,
              );
            } else {
              snackbarMessenger(
                context,
                MediaQuery.of(context).size.width * 0.35,
                Colors.red,
                response['message'],
                MediaQuery.of(context).size.height * 0.6,
              );
            }
          }).catchError((error) {
            Navigator.pop(context);

            snackbarMessenger(
              context,
              MediaQuery.of(context).size.width * 0.35,
              Colors.red,
              'Gagal terhubung ke server',
              MediaQuery.of(context).size.height * 0.6,
            );
          });
          duration!.cancel();
        }
      });
    });
  }

  timeSubstract(String date, String startTime, String endTime) {
    final difference = DateTime.parse('$date $endTime')
        .difference(DateTime.parse('$date $startTime'));

    final inHours = difference.inHours;
    final inMinutes = difference.inMinutes.remainder(60);
    final inSeconds = difference.inSeconds.remainder(60);

    return '${inHours.toString().length == 1 ? "0$inHours" : inHours}:${inMinutes.toString().length == 1 ? "0$inMinutes" : inMinutes}:${inSeconds.toString().length == 1 ? "0$inSeconds" : inSeconds}';
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
      body: getData
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
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
                    Text('loading')
                  ],
                )
              ],
            )
          : PopScope(
              canPop: !start,
              child: ListView(
                children: [
                  int.parse(data[0]['created_by_guide'].toString()) == 1 &&
                          (DateTime.now()
                                  .add(const Duration(minutes: 30))
                                  .isAfter(DateTime.parse(
                                      '${data[0]["date"]} ${data[0]["end_time"]}')) ||
                              checkIfDataDone(data))
                      ? Container(
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05),
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
                                        height: data.length * 50 > 300
                                            ? 300
                                            : (data.isEmpty
                                                ? 100
                                                : double.parse(
                                                    (data.length * 50)
                                                        .toString())),
                                        child: ListView(
                                          children: data
                                              .map<Widget>(
                                                (data) => OutlinedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      emailFilter =
                                                          data['email'];
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  style: const ButtonStyle(
                                                    shape:
                                                        MaterialStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(8.0),
                                                        ),
                                                      ),
                                                    ),
                                                    padding:
                                                        MaterialStatePropertyAll(
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
                                                        textAlign:
                                                            TextAlign.left,
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
                                      filter(data, emailFilter)['user_name'],
                                      style:
                                          const TextStyle(color: Colors.black),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  rowInformation(
                    context,
                    'Nama Aktivitas',
                    int.parse(data[0]['created_by_guide'].toString()) == 1 &&
                            (DateTime.now()
                                .add(const Duration(minutes: 30))
                                .isAfter(DateTime.parse(
                                    '${data[0]["date"]} ${data[0]["end_time"]}')))
                        ? filter(data, emailFilter)['name'].toString()
                        : data[0]['name'].toString(),
                    25.0,
                  ),
                  rowInformation(
                    context,
                    'Waktu Pelaksanaan',
                    '${convertDateToString(data[0]["date"].toString())} (${handleTime(data[0]["start_time"].toString())} - ${handleTime(data[0]["end_time"].toString())})',
                    15.0,
                  ),
                  rowInformation(
                    context,
                    'Keterangan',
                    DateTime.now().add(const Duration(minutes: 30)).isAfter(
                                DateTime.parse(
                                    '${data[0]["date"]} ${data[0]["end_time"]}')) ||
                            checkIfDataDone(data)
                        ? (filter(data, emailFilter)['note'] ?? '-')
                        : data[0]['note'] ?? '-',
                    15.0,
                  ),
                  rowInformation(
                    context,
                    'Waktu Mulai',
                    DateTime.now().add(const Duration(minutes: 30)).isAfter(
                                DateTime.parse(
                                    '${data[0]["date"]} ${data[0]["end_time"]}')) ||
                            checkIfDataDone(data)
                        ? (filter(data, emailFilter)['start_activity_time'] ??
                            '-')
                        : (startTime == '' ? '-' : startTime),
                    15.0,
                  ),
                  rowInformation(
                    context,
                    'Waktu Selesai',
                    DateTime.now().add(const Duration(minutes: 30)).isAfter(
                                DateTime.parse(
                                    '${data[0]["date"]} ${data[0]["end_time"]}')) ||
                            checkIfDataDone(data)
                        ? filter(
                                data, emailFilter)['finishing_activity_time'] ??
                            '-'
                        : (endTime == '' ? '-' : endTime),
                    15.0,
                  ),
                  Consumer<Activity>(
                    builder: (context, activity, child) => rowInformation(
                      context,
                      'Durasi',
                      DateTime.parse('${data[0]["date"]} ${data[0]["end_time"]}')
                                  .isBefore(DateTime.now()) ||
                              checkIfDataDone(data)
                          ? (filter(data, emailFilter)[
                                      'finishing_activity_time'] !=
                                  null
                              ? timeSubstract(
                                  filter(data, emailFilter)['date'],
                                  filter(
                                      data, emailFilter)['start_activity_time'],
                                  filter(data, emailFilter)[
                                      'finishing_activity_time'])
                              : '-')
                          : '${activity.hours.toString().length == 1 ? "0${activity.hours}" : activity.hours}:${activity.minutes.toString().length == 1 ? "0${activity.minutes}" : activity.minutes}:${activity.seconds.toString().length == 1 ? "0${activity.seconds}" : activity.seconds}',
                      15.0,
                    ),
                  ),
                  data.length > 1 &&
                          (DateTime.parse(
                                      '${data[0]["date"]} ${data[0]["end_time"]}')
                                  .isBefore(DateTime.now()) ||
                              checkIfDataDone(data)) &&
                          emailFilter ==
                              Provider.of<User>(context, listen: false)
                                  .userEmail
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: filterParticipantStatus(data, true)
                                    .map<Widget>(
                                      (data) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0, vertical: 6.0),
                                        alignment: Alignment.centerLeft,
                                        decoration: const BoxDecoration(
                                          color:
                                              Color.fromRGBO(1, 98, 104, 1.0),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                        ),
                                        child: Text(
                                          data['user_name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
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
                                children: filterParticipantStatus(data, false)
                                    .map<Widget>(
                                      (data) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0, vertical: 6.0),
                                        alignment: Alignment.centerLeft,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                        ),
                                        child: Text(
                                          data['user_name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
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
                        ),
                        Consumer<Activity>(
                          builder: (context, activity, child) => MarkerLayer(
                            markers: activity.coordinates
                                .map<Marker>(
                                  (coordinate) => Marker(
                                    point: coordinate,
                                    width: 12,
                                    height: 12,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  !checkIfDataDone(data) &&
                          DateTime.parse(
                                  '${data[0]["date"]} ${data[0]["end_time"]}')
                              .isAfter(DateTime.now())
                      ? Container(
                          margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.1,
                            right: MediaQuery.of(context).size.width * 0.1,
                            bottom: 30.0,
                          ),
                          child: FilledButton(
                            onPressed: () async {
                              LocationPermission geolocatorPermission =
                                  await Geolocator.checkPermission();
                              if (geolocatorPermission !=
                                      LocationPermission.always &&
                                  geolocatorPermission !=
                                      LocationPermission.whileInUse) {
                                await Geolocator.requestPermission();
                              } else {
                                if (start) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      surfaceTintColor: Colors.white,
                                      backgroundColor: Colors.white,
                                      titlePadding: const EdgeInsets.only(
                                        left: 20.0,
                                        right: 17.0,
                                        top: 4.0,
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Peringatan',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(Ionicons.md_close),
                                          )
                                        ],
                                      ),
                                      content: const Text(
                                        'Apakah anda yakin menyelesaikan aktivitas?',
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  right: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.04),
                                              child: FilledButton(
                                                style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                    Color.fromRGBO(
                                                        248, 198, 48, 1),
                                                  ),
                                                  shape:
                                                      MaterialStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(8.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Batal',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.04),
                                              child: FilledButton(
                                                style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                    Color.fromRGBO(
                                                        1, 98, 104, 1.0),
                                                  ),
                                                  shape:
                                                      MaterialStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(8.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  DateTime now = DateTime.now();
                                                  setState(() {
                                                    endTime =
                                                        '${now.hour.toString().length == 1 ? "0${now.hour}" : now.hour}:${now.minute.toString().length == 1 ? "0${now.minute}" : now.minute}:${now.second.toString().length == 1 ? "0${now.second}" : now.second}';
                                                  });

                                                  duration!.cancel();

                                                  if (data.length > 1) {
                                                    Navigator.pop(context);

                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          StatefulBuilder(
                                                              builder: (context,
                                                                  setState) {
                                                        return PopScope(
                                                          canPop: false,
                                                          child: AlertDialog(
                                                            surfaceTintColor:
                                                                Colors.white,
                                                            backgroundColor:
                                                                Colors.white,
                                                            titlePadding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 20.0,
                                                              right: 20.0,
                                                              top: 15.0,
                                                            ),
                                                            scrollable: true,
                                                            title: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.5,
                                                                  child:
                                                                      const Text(
                                                                    'Peserta kegiatan yang hadir',
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      endTime =
                                                                          '';
                                                                    });

                                                                    countingDuration();

                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  icon:
                                                                      const Icon(
                                                                    Ionicons
                                                                        .md_close,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            content: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                  'Daftar peserta:',
                                                                ),
                                                                Container(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.3,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border
                                                                        .all(),
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                      Radius.circular(
                                                                          8.0),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      ListView(
                                                                    children:
                                                                        participants
                                                                            .map(
                                                                              (element) => Container(
                                                                                margin: const EdgeInsets.only(
                                                                                  left: 5.0,
                                                                                  right: 5.0,
                                                                                  top: 3.0,
                                                                                ),
                                                                                child: FilledButton(
                                                                                  onPressed: () {
                                                                                    setState(() {
                                                                                      presentParticipants.add(element);
                                                                                      participants.remove(element);
                                                                                    });
                                                                                  },
                                                                                  style: const ButtonStyle(
                                                                                    shape: MaterialStatePropertyAll(
                                                                                      RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.all(
                                                                                          Radius.circular(8.0),
                                                                                        ),
                                                                                        side: BorderSide(),
                                                                                      ),
                                                                                    ),
                                                                                    backgroundColor: MaterialStatePropertyAll(Colors.white),
                                                                                    padding: MaterialStatePropertyAll(
                                                                                      EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
                                                                                    ),
                                                                                    alignment: Alignment.centerLeft,
                                                                                  ),
                                                                                  child: Text(
                                                                                    element['user_name'],
                                                                                    style: const TextStyle(
                                                                                      color: Colors.black,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                            .toList(),
                                                                  ),
                                                                ),
                                                                const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                              top: 8.0),
                                                                  child: Text(
                                                                    'Daftar peserta hadir:',
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.3,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border
                                                                        .all(),
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                      Radius.circular(
                                                                          8.0),
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      ListView(
                                                                    children:
                                                                        presentParticipants
                                                                            .map(
                                                                              (element) => Container(
                                                                                margin: const EdgeInsets.only(
                                                                                  left: 5.0,
                                                                                  right: 5.0,
                                                                                  top: 3.0,
                                                                                ),
                                                                                child: FilledButton(
                                                                                  onPressed: () {
                                                                                    setState(() {
                                                                                      presentParticipants.remove(element);
                                                                                      participants.add(element);
                                                                                    });
                                                                                  },
                                                                                  style: const ButtonStyle(
                                                                                    shape: MaterialStatePropertyAll(
                                                                                      RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.all(
                                                                                          Radius.circular(8.0),
                                                                                        ),
                                                                                        side: BorderSide.none,
                                                                                      ),
                                                                                    ),
                                                                                    backgroundColor: MaterialStatePropertyAll(Color.fromRGBO(1, 98, 104, 1.0)),
                                                                                    padding: MaterialStatePropertyAll(
                                                                                      EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
                                                                                    ),
                                                                                    alignment: Alignment.centerLeft,
                                                                                  ),
                                                                                  child: Text(
                                                                                    element['user_name'],
                                                                                    style: const TextStyle(
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                            .toList(),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            actions: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    margin: EdgeInsets.only(
                                                                        right: MediaQuery.of(context).size.width *
                                                                            0.04),
                                                                    child:
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
                                                                        shape:
                                                                            MaterialStatePropertyAll(
                                                                          RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(
                                                                              Radius.circular(8.0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          endTime =
                                                                              '';
                                                                        });

                                                                        countingDuration();

                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        'Batal',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets.only(
                                                                        left: MediaQuery.of(context).size.width *
                                                                            0.04),
                                                                    child:
                                                                        FilledButton(
                                                                      style:
                                                                          const ButtonStyle(
                                                                        backgroundColor:
                                                                            MaterialStatePropertyAll(
                                                                          Color.fromRGBO(
                                                                              1,
                                                                              98,
                                                                              104,
                                                                              1.0),
                                                                        ),
                                                                        shape:
                                                                            MaterialStatePropertyAll(
                                                                          RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(
                                                                              Radius.circular(8.0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        duration!
                                                                            .cancel();

                                                                        loadingIndicator(
                                                                            context);

                                                                        Provider.of<Activity>(context,
                                                                                listen: false)
                                                                            .finishActivity(
                                                                          data[0]['id']
                                                                              .toString(),
                                                                          startTime,
                                                                          endTime,
                                                                          Provider.of<Activity>(context, listen: false)
                                                                              .coordinates,
                                                                          presentParticipants,
                                                                        )
                                                                            .then((response) {
                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.pop(
                                                                              context);

                                                                          if (response['status'] ==
                                                                              'success') {
                                                                            Navigator.pop(context,
                                                                                true);

                                                                            snackbarMessenger(
                                                                              context,
                                                                              MediaQuery.of(context).size.width * 0.35,
                                                                              const Color.fromARGB(255, 0, 120, 18),
                                                                              'berhasil menyelesaikan kegiatan',
                                                                              MediaQuery.of(context).size.height * 0.6,
                                                                            );
                                                                          } else {
                                                                            snackbarMessenger(
                                                                              context,
                                                                              MediaQuery.of(context).size.width * 0.35,
                                                                              Colors.red,
                                                                              response['message'],
                                                                              MediaQuery.of(context).size.height * 0.6,
                                                                            );
                                                                          }
                                                                        }).catchError((error) {
                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.pop(
                                                                              context);

                                                                          snackbarMessenger(
                                                                            context,
                                                                            MediaQuery.of(context).size.width *
                                                                                0.35,
                                                                            Colors.red,
                                                                            'gagal terhubung ke server',
                                                                            MediaQuery.of(context).size.height *
                                                                                0.6,
                                                                          );
                                                                        });
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        'Iya',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                    ).then((value) {
                                                      setState(() {});
                                                    });
                                                  } else {
                                                    loadingIndicator(context);

                                                    Provider.of<Activity>(
                                                            context,
                                                            listen: false)
                                                        .finishActivity(
                                                      data[0]['id'].toString(),
                                                      startTime,
                                                      endTime,
                                                      Provider.of<Activity>(
                                                              context,
                                                              listen: false)
                                                          .coordinates,
                                                      presentParticipants,
                                                    )
                                                        .then((response) {
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);

                                                      if (response['status'] ==
                                                          'success') {
                                                        Navigator.pop(
                                                            context, true);

                                                        snackbarMessenger(
                                                          context,
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.35,
                                                          const Color.fromARGB(
                                                              255, 0, 120, 18),
                                                          'berhasil menyelesaikan kegiatan',
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.6,
                                                        );
                                                      } else {
                                                        snackbarMessenger(
                                                          context,
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.35,
                                                          Colors.red,
                                                          response['message'],
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.6,
                                                        );
                                                      }
                                                    }).catchError((error) {
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);

                                                      snackbarMessenger(
                                                        context,
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.35,
                                                        Colors.red,
                                                        'gagal terhubung ke server',
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.6,
                                                      );
                                                    });
                                                  }
                                                },
                                                child: const Text(
                                                  'Iya',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      surfaceTintColor: Colors.white,
                                      backgroundColor: Colors.white,
                                      titlePadding: const EdgeInsets.only(
                                        left: 20.0,
                                        right: 17.0,
                                        top: 4.0,
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Peringatan',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(Ionicons.md_close),
                                          )
                                        ],
                                      ),
                                      content: const Text(
                                        'Apakah anda yakin akan memulai aktivitas?',
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  right: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.04),
                                              child: FilledButton(
                                                style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                    Color.fromRGBO(
                                                        248, 198, 48, 1),
                                                  ),
                                                  shape:
                                                      MaterialStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(8.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Batal',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.04),
                                              child: FilledButton(
                                                style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                    Color.fromRGBO(
                                                        1, 98, 104, 1.0),
                                                  ),
                                                  shape:
                                                      MaterialStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(8.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  DateTime now = DateTime.now();
                                                  setState(() {
                                                    start = true;
                                                    startTime =
                                                        '${now.hour.toString().length == 1 ? "0${now.hour}" : now.hour}:${now.minute.toString().length == 1 ? "0${now.minute}" : now.minute}:${now.second.toString().length == 1 ? "0${now.second}" : now.second}';
                                                  });

                                                  countingDuration();

                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  'Iya',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
