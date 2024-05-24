import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/circle_button.dart';
import 'package:modis/components/custom_navigation_bar.dart';
import 'package:modis/components/floating_action_button_modis.dart';
import 'package:modis/pages/bmi_calculator.dart';
import 'package:modis/pages/create_edit_activities.dart';
import 'package:modis/pages/dilans_events.dart';
import 'package:modis/pages/weight_tracker.dart';
import 'package:modis/providers/activity.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  @override
  void initState() {
    super.initState();
    getAllActivity();
  }

  getAllActivity() {
    Provider.of<Activity>(context, listen: false)
        .getListActivities()
        .then((response) {
      if (response['status'] == 'error') {
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateTime.now().hour < 11
                  ? 'Selamat Pagi,'
                  : (DateTime.now().hour < 17
                      ? 'Selamat Siang,'
                      : 'Selamat Malam,'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            Container(
              width: 250,
              margin: const EdgeInsets.only(top: 6.0),
              child: Consumer<User>(
                builder: (context, user, child) => Text(
                  user.userFullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            )
          ],
        ),
        action: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications,
            size: 27,
            color: Colors.white,
          ),
        ),
        noFreeSpace: true,
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 75,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color.fromRGBO(1, 92, 104, 1),
                      Color.fromRGBO(1, 135, 76, 1),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 120,
                margin:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(17)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 96, 96, 96),
                      offset: Offset(0, 0.5),
                    ),
                    BoxShadow(
                      color: Color.fromARGB(255, 140, 140, 140),
                      offset: Offset(0, 1.5),
                    ),
                    BoxShadow(
                      color: Color.fromARGB(255, 205, 205, 205),
                      offset: Offset(0, 2.5),
                    ),
                    BoxShadow(
                      color: Color.fromARGB(255, 96, 96, 96),
                      offset: Offset(0.5, 0.5),
                    ),
                    BoxShadow(
                      color: Color.fromARGB(255, 96, 96, 96),
                      offset: Offset(-0.5, 0.5),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleButtonModis(
                      icon: Ionicons.md_calculator,
                      label: 'Kalkulator Kesehatan',
                      colors: const [
                        Color.fromRGBO(198, 193, 255, 1),
                        Color.fromRGBO(19, 0, 242, 1),
                      ],
                      margin: const EdgeInsets.only(right: 12.0),
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                                milliseconds: 300), // Durasi animasi
                            pageBuilder: (BuildContext context,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation) {
                              return const BMICalculator();
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
                      },
                    ),
                    CircleButtonModis(
                      icon: Ionicons.md_analytics,
                      label: 'Lacak Berat Badan',
                      colors: const [
                        Color.fromRGBO(148, 255, 146, 1),
                        Color.fromRGBO(0, 160, 35, 1),
                      ],
                      margin: EdgeInsets.zero,
                      onPressed: () {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                                milliseconds: 300), // Durasi animasi
                            pageBuilder: (BuildContext context,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation) {
                              return WeightTracker(
                                userEmail:
                                    Provider.of<User>(context, listen: false)
                                        .userEmail,
                                isGuide: false,
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
                        );
                      },
                    ),
                    CircleButtonModis(
                      icon: Icons.event,
                      label: 'DILANS Events',
                      colors: const [
                        Color.fromRGBO(165, 118, 201, 1),
                        Color.fromRGBO(56, 0, 99, 1),
                      ],
                      margin: const EdgeInsets.only(left: 12.0),
                      onPressed: () {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                                milliseconds: 300), // Durasi animasi
                            pageBuilder: (BuildContext context,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation) {
                              return const DilansEvents();
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
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                    onPressed: () {},
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
                          horizontal: 8.0,
                          vertical: 3.0,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_list_outlined,
                          color: Colors.black,
                        ),
                        Text(
                          'Filter',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ))
              ],
            ),
          ),
          Consumer<Activity>(
            builder: (context, activity, child) => activity.loadingGetData
                ? Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.25),
                    child: const Row(
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
                  )
                : activity.dateActivities.isNotEmpty
                    ? Column(
                        children: [
                          ButtonDropdownActivities(
                              date: 'Hari ini', activity: activity),
                          Column(
                            children: activity.dateActivities
                                .map<Widget>(
                                  (date) => ButtonDropdownActivities(
                                      date: date, activity: activity),
                                )
                                .toList(),
                          )
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.25),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [Text('Tidak ada data')],
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButtonModis(onPressed: () {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration:
                const Duration(milliseconds: 300), // Durasi animasi
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return const CreateEditActivity();
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
            Provider.of<Activity>(context, listen: false).setLoadingGetData();
            getAllActivity();
          }
        });
      }),
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentIndex: 0,
      ),
    );
  }
}

class ButtonDropdownActivities extends StatefulWidget {
  const ButtonDropdownActivities({
    super.key,
    required this.date,
    required this.activity,
  });
  final String date;
  final dynamic activity;

  @override
  State<ButtonDropdownActivities> createState() =>
      _ButtonDropdownActivitiesState();
}

class _ButtonDropdownActivitiesState extends State<ButtonDropdownActivities> {
  bool open = false;

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

  convertDateToString(String date) {
    List<String> splitDate = date.split('-');
    return '${splitDate[2]} ${month[splitDate[1]]} ${splitDate[0]}';
  }

  getAllActivity() {
    Provider.of<Activity>(context, listen: false).setLoadingGetData();

    Provider.of<Activity>(context, listen: false)
        .getListActivities()
        .then((response) {
      if (response['status'] == 'error') {}
    }).catchError((error) {});
  }

  showAction(element) {
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
                icon: Icons.play_arrow,
                label: 'Mulai',
                colors: const [
                  Color.fromARGB(255, 0, 84, 13),
                  Color.fromARGB(255, 40, 196, 63),
                ],
                margin: const EdgeInsets.only(
                  top: 8.0,
                  bottom: 8.0,
                  left: 20.0,
                ),
                onPressed: () {},
              ),
              element['created_by_guide'] == '1' &&
                      Provider.of<User>(context, listen: false).userRole == 0
                  ? Container()
                  : CircleButtonModis(
                      icon: Icons.edit,
                      label: 'Ubah',
                      colors: const [
                        Color.fromARGB(255, 162, 111, 0),
                        Color.fromARGB(255, 255, 202, 87),
                      ],
                      margin: const EdgeInsets.only(
                        top: 8.0,
                        bottom: 8.0,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        Provider.of<Activity>(context, listen: false)
                            .getDetailActivities(element['id'])
                            .then((response) {
                          Navigator.pop(context);
                          if (response['status'] == 'success') {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(
                                    milliseconds: 300), // Durasi animasi
                                pageBuilder: (BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secondaryAnimation) {
                                  return CreateEditActivity(
                                    data: response['data'],
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
                              if (value) {
                                getAllActivity();
                              }
                            });
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
                      },
                    ),
              element['created_by_guide'] == '1' &&
                      Provider.of<User>(context, listen: false).userRole == 0
                  ? Container()
                  : CircleButtonModis(
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
                              'Apakah yakin menghapus kegiatan?',
                            ),
                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              FilledButton(
                                style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
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
                                  backgroundColor: MaterialStatePropertyAll(
                                    Colors.red,
                                  ),
                                ),
                                onPressed: () {
                                  Provider.of<Activity>(context, listen: false)
                                      .deleteActivity(element['id'].toString())
                                      .then((response) {
                                    Navigator.pop(context);
                                    if (response['status'] == 'success') {
                                      snackbarMessenger(
                                        context,
                                        MediaQuery.of(context).size.width *
                                            0.35,
                                        const Color.fromARGB(255, 0, 120, 18),
                                        'berhasil menghapus kegiatan',
                                        MediaQuery.of(context).size.height *
                                            0.6,
                                      );
                                      getAllActivity();
                                    } else {
                                      snackbarMessenger(
                                        context,
                                        MediaQuery.of(context).size.width *
                                            0.35,
                                        Colors.red,
                                        response['message'],
                                        MediaQuery.of(context).size.height *
                                            0.6,
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

  filterDataBasedDate(dynamic activity) {
    String date = widget.date == 'Hari ini'
        ? DateTime.now().toString().split(' ')[0]
        : widget.date;
    return activity.where((element) => element['date'] == date).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.01),
      child: Column(
        children: [
          OutlinedButton(
            onPressed: () {
              setState(() {
                open = !open;
              });
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
                  horizontal: 8.0,
                  vertical: 3.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.date == 'Hari ini'
                      ? 'Hari ini'
                      : convertDateToString(widget.date),
                  style: const TextStyle(color: Colors.black),
                ),
                open
                    ? const Icon(Icons.keyboard_arrow_down)
                    : const Icon(Icons.keyboard_arrow_left),
              ],
            ),
          ),
          open
              ? Column(
                  children: filterDataBasedDate(
                          widget.activity.listMyActivities)
                      .map<Widget>(
                        (element) => Container(
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.01),
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              DateTime.now().isAfter(DateTime.parse(
                                          '${element["date"]} ${element["start_time"]}')) ||
                                      int.parse(element['done'].toString()) == 1
                                  ? Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(
                                            milliseconds:
                                                300), // Durasi animasi
                                        pageBuilder: (BuildContext context,
                                            Animation<double> animation,
                                            Animation<double>
                                                secondaryAnimation) {
                                          return const CreateEditActivity();
                                        },
                                        transitionsBuilder:
                                            (BuildContext context,
                                                Animation<double> animation,
                                                Animation<double>
                                                    secondaryAnimation,
                                                Widget child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    )
                                  : showAction(element);
                            },
                            style: const ButtonStyle(
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      8.0,
                                    ),
                                  ),
                                ),
                              ),
                              padding: MaterialStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 3.0,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  element['name'],
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                )
              : Container(),
        ],
      ),
    );
    ;
  }
}
