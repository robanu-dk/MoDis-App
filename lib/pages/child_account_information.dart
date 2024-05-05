import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/flex_row_information.dart';
import 'package:modis/pages/weight_tracker.dart';
import 'package:modis/providers/activity.dart';
import 'package:modis/providers/child.dart';
import 'package:modis/providers/weight.dart';
import 'package:provider/provider.dart';

class ChildAccountInformation extends StatelessWidget {
  const ChildAccountInformation({
    super.key,
    required this.data,
  });
  final dynamic data;

  void snackbarMessenger(BuildContext context, double leftPadding,
      Color backgroundColor, String message, double bottom) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: leftPadding,
          right: 9,
          bottom: bottom,
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
              'Informasi Akun',
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150,
              width: 150,
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 2),
                    blurRadius: 1.0,
                  ),
                ],
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                child:
                    data['profile_image'] == null || data['profile_image'] == ''
                        ? Image.asset(
                            'images/default_profile_image.jpg',
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            'https://modis.techcreator.my.id/${data["profile_image"]}?timestamp=${DateTime.fromMillisecondsSinceEpoch(100)}',
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover,
                          ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  FlexRowInformation(
                    widthValue: MediaQuery.of(context).size.width * 0.5,
                    label: 'Nama Lengkap',
                    value: data['name'],
                  ),
                  FlexRowInformation(
                    widthValue: MediaQuery.of(context).size.width * 0.5,
                    label: 'Nama Pengguna',
                    value: data['username'],
                  ),
                  FlexRowInformation(
                    widthValue: MediaQuery.of(context).size.width * 0.5,
                    label: 'Email',
                    value: data['email'],
                  ),
                  FlexRowInformation(
                    widthValue: MediaQuery.of(context).size.width * 0.5,
                    label: 'Jenis Kelamin',
                    value: data['gender'] == 1 ? 'Perempuan' : 'Laki-Laki',
                  ),
                  Consumer<Weight>(
                    builder: (context, weight, child) => FlexRowInformation(
                      widthValue: MediaQuery.of(context).size.width * 0.5,
                      label: 'Berat Badan',
                      value: weight.listWeightUser == null ||
                              weight.listWeightUser.length == 0
                          ? '-'
                          : '${weight.listWeightUser[0]["weight"]} kg',
                    ),
                  ),
                  Consumer<Activity>(
                    builder: (context, activity, child) => activity
                                    .listTodayActivity !=
                                null &&
                            activity.listTodayActivity.length != 0
                        ? Column(
                            children: [
                              const FlexRowInformation(
                                label: 'Kegiatan Hari Ini',
                                value: '',
                              ),
                              Column(
                                children:
                                    activity.listTodayActivity.map<Widget>(
                                  (element) {
                                    var startTime = element['start_time']
                                        .toString()
                                        .split(':');
                                    var endTime = element['end_time']
                                        .toString()
                                        .split(':');
                                    return Container(
                                      margin: const EdgeInsets.only(
                                        top: 8.0,
                                      ),
                                      height: 30,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Text(
                                              element['name'],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Text(
                                              '${startTime[0]}:${startTime[1]} - ${endTime[0]}:${endTime[1]}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          )
                        : FlexRowInformation(
                            widthValue: MediaQuery.of(context).size.width * 0.5,
                            label: 'Kegiatan Hari Ini',
                            value: 'Tidak ada kegiatan hari ini',
                          ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 30.0),
              child: IconButton(
                style: const ButtonStyle(
                  padding: MaterialStatePropertyAll(EdgeInsets.all(3.0)),
                ),
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
                        return WeightTracker(
                          userEmail: data['email'],
                          isGuide: true,
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
                icon: Container(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                    left: 12.0,
                    right: 12.0,
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(1, 98, 104, 1),
                        Color.fromRGBO(1, 135, 76, 1)
                      ],
                    ),
                  ),
                  child: const Text(
                    'Lacak Berat Badan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 15.0),
              child: FilledButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            surfaceTintColor: Colors.white,
                            actionsAlignment: MainAxisAlignment.spaceAround,
                            title: const Text('Peringatan'),
                            content: const Text(
                                'Apakah yakin menghapus akun dari daftar?'),
                            actions: [
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                    Color.fromRGBO(248, 198, 48, 1),
                                  ),
                                ),
                                child: const Text('Batal'),
                              ),
                              FilledButton(
                                style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                    Color.fromRGBO(160, 0, 0, 1),
                                  ),
                                ),
                                onPressed: () {
                                  loadingIndicator(context);
                                  Provider.of<Child>(context, listen: false)
                                      .removeChildFromListAccountBasedGuide(
                                          data['email'])
                                      .then((response) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    if (response['status'] == 'success') {
                                      Navigator.pop(context);
                                      snackbarMessenger(
                                        context,
                                        MediaQuery.of(context).size.width * 0.5,
                                        const Color.fromARGB(255, 0, 120, 18),
                                        'berhasil menghapus pengguna',
                                        MediaQuery.of(context).size.height *
                                            0.6,
                                      );
                                    } else {
                                      snackbarMessenger(
                                        context,
                                        MediaQuery.of(context).size.width * 0.4,
                                        Colors.red,
                                        response['message'],
                                        MediaQuery.of(context).size.height *
                                            0.7,
                                      );
                                    }
                                  }).catchError((error) {
                                    snackbarMessenger(
                                      context,
                                      MediaQuery.of(context).size.width * 0.4,
                                      Colors.red,
                                      'Gagal terhubung ke server',
                                      MediaQuery.of(context).size.height * 0.7,
                                    );
                                  });
                                },
                                child: const Text('Hapus'),
                              ),
                            ],
                          ));
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Color.fromRGBO(160, 0, 0, 1),
                  ),
                ),
                child: const Text(
                  'Hapus dari Akun Terhubung',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
