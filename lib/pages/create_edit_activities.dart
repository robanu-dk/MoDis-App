import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/alert_input_implement.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/input_implement.dart';
import 'package:modis/components/search_input.dart';
import 'package:modis/providers/child.dart';
import 'package:modis/providers/user.dart';
import 'package:provider/provider.dart';

class CreateEditActivity extends StatefulWidget {
  const CreateEditActivity({super.key, this.data});
  final dynamic data;

  @override
  State<CreateEditActivity> createState() => _CreateEditActivityState();
}

class _CreateEditActivityState extends State<CreateEditActivity> {
  TextEditingController name = TextEditingController(),
      date = TextEditingController(),
      startTime = TextEditingController(),
      endTime = TextEditingController(),
      note = TextEditingController();

  FocusNode fName = FocusNode(),
      fDate = FocusNode(),
      fStartTime = FocusNode(),
      fEndTime = FocusNode(),
      fNote = FocusNode(),
      fSearchChild = FocusNode();

  List<dynamic> participantList = [], participantIdList = [];

  String? dateInput, searchChild;

  bool refresh = true;

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

  String convertDateToString(String date) {
    List splitDate = date.split('-');
    return '${splitDate[2]} ${month[splitDate[1]]} ${splitDate[0]}';
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

  dynamic search({data, filter}) {
    if (data == null) {
      return [];
    }

    if (participantList.isEmpty) {
      if (filter != '' && filter != null) {
        return data.where((element) {
          String resource =
              element['name'].toString().replaceAll(' ', '').toLowerCase();
          String keyword = filter.toString().replaceAll(' ', '').toLowerCase();
          return resource.contains(keyword);
        }).toList();
      } else {
        return data;
      }
    } else {
      if (filter != '' && filter != null) {
        return data.where((element) {
          String resource =
              element['name'].toString().replaceAll(' ', '').toLowerCase();
          String keyword = filter.toString().replaceAll(' ', '').toLowerCase();
          return resource.contains(keyword) &&
              !participantIdList.contains(element['id']);
        }).toList();
      } else {
        return data
            .where((element) => !participantIdList.contains(element['id']));
      }
    }
  }

  Widget childAccountWidget(data) {
    return OutlinedButton(
      onPressed: () {
        participantList.add(data);
        participantIdList.add(data['id']);
        setState(() {
          refresh = true;
        });
        Navigator.pop(context);
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
          EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
        ),
      ),
      child: Row(
        children: [
          data['profile_image'] == null
              ? ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                  child: Image.asset(
                    'images/default_profile_image.jpg',
                    height: 30.0,
                    width: 30.0,
                    fit: BoxFit.cover,
                  ),
                )
              : ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                  child: Image.network(
                    'https://modis.techcreator.my.id/${data["profile_image"]}?timestamp=${DateTime.fromMillisecondsSinceEpoch(100)}',
                    height: 30.0,
                    width: 30.0,
                    fit: BoxFit.cover,
                  ),
                ),
          Container(
            width: MediaQuery.of(context).size.width - 185,
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              data['name'],
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  showListChildAccount() {
    setState(() {
      searchChild = null;
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertInput(
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Informasi Akun',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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
          headerPadding: EdgeInsets.zero,
          contents: [
            SearchModis(
              focusNode: fSearchChild,
              onSubmitted: (value) {
                setState(() {
                  searchChild = value;
                });
              },
              label: const Text(
                'Ketik disini untuk pencarian',
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            Consumer<Child>(
              builder: (context, childAccount, child) => Container(
                margin: const EdgeInsets.only(top: 4.0),
                height: search(
                          data: childAccount.listChild,
                          filter: searchChild,
                        ).length ==
                        0
                    ? 50
                    : (search(
                                  data: childAccount.listChild,
                                  filter: searchChild,
                                ).length *
                                50.0 >
                            500
                        ? 500
                        : search(
                              data: childAccount.listChild,
                              filter: searchChild,
                            ).length *
                            50.0),
                child: search(
                          data: childAccount.listChild,
                          filter: searchChild,
                        ).length ==
                        0
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Text('Data tidak ditemukan')],
                      )
                    : ListView(
                        children: search(
                                data: childAccount.listChild,
                                filter: searchChild)
                            .map<Widget>(
                              (account) => childAccountWidget(account),
                            )
                            .toList(),
                      ),
              ),
            ),
          ],
          contentAligment: 'vertical',
          contentPadding: const EdgeInsets.only(top: 8.0),
          actionAligment: 'horizontal',
          actions: const [],
          actionPadding: EdgeInsets.zero,
        );
      }),
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
              'Buat Aktivitas Baru',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Input(
              focusNode: fName,
              textController: name,
              label: 'Nama Kegiatan',
              border: const OutlineInputBorder(),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Input(
              focusNode: fDate,
              textController: date,
              suffixIcon: const Icon(Icons.calendar_month_outlined),
              label: 'Tanggal',
              border: const OutlineInputBorder(),
              readonly: true,
              onTap: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    surfaceTintColor: Colors.white,
                    backgroundColor: Colors.white,
                    scrollable: true,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text(
                            'Pilih Tanggal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            fDate.unfocus();
                          },
                          icon: const Icon(Ionicons.md_close),
                        )
                      ],
                    ),
                    content: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: CalendarDatePicker(
                        initialDate: dateInput == null
                            ? DateTime.now()
                            : DateTime(
                                int.parse(dateInput!.split('-')[0]),
                                int.parse(dateInput!.split('-')[1]),
                                int.parse(dateInput!.split('-')[2])),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        onDateChanged: (selectedDate) {
                          date.text = convertDateToString(
                              selectedDate.toString().split(' ')[0]);
                          setState(() {
                            dateInput = selectedDate.toString().split(' ')[0];
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Input(
              focusNode: fStartTime,
              textController: startTime,
              label: 'Waktu Mulai',
              border: const OutlineInputBorder(),
              readonly: true,
              suffixIcon: const Icon(Icons.access_time_sharp),
              onTap: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                showDialog(
                  context: context,
                  builder: (context) => TimePickerDialog(
                    initialTime: TimeOfDay.now(),
                    confirmText: 'Pilih',
                    cancelText: 'Batal',
                  ),
                ).then((value) {
                  fStartTime.unfocus();
                  if (value != null) {
                    startTime.text =
                        '${value.hour.toString().length == 1 ? "0${value.hour}" : value.hour}:${value.minute.toString().length == 1 ? "0${value.minute}" : value.minute}';
                  }
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Input(
              focusNode: fEndTime,
              textController: endTime,
              label: 'Waktu Selesai',
              border: const OutlineInputBorder(),
              readonly: true,
              suffixIcon: const Icon(Icons.access_time_sharp),
              onTap: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                showDialog(
                  context: context,
                  builder: (context) => TimePickerDialog(
                    initialTime: TimeOfDay.now(),
                    confirmText: 'Pilih',
                    cancelText: 'Batal',
                  ),
                ).then((value) {
                  fEndTime.unfocus();
                  if (value != null) {
                    endTime.text =
                        '${value.hour.toString().length == 1 ? "0${value.hour}" : value.hour}:${value.minute.toString().length == 1 ? "0${value.minute}" : value.minute}';
                  }
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Input(
              focusNode: fNote,
              textController: note,
              label: 'Keterangan',
              border: const OutlineInputBorder(),
            ),
          ),
          Provider.of<User>(context, listen: false).userRole == 1
              ? Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: 20.0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(120, 120, 120, 1),
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      FilledButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          Provider.of<Child>(context, listen: false)
                              .getListData()
                              .then((response) {
                            if (response['status'] == 'error') {
                              snackbarMessenger(
                                context,
                                MediaQuery.of(context).size.width * 0.35,
                                Colors.red,
                                'gagal terhubung ke server',
                                MediaQuery.of(context).size.height * 0.72,
                              );
                            }
                          }).catchError((error) {
                            snackbarMessenger(
                              context,
                              MediaQuery.of(context).size.width * 0.35,
                              Colors.red,
                              'gagal terhubung ke server',
                              MediaQuery.of(context).size.height * 0.72,
                            );
                          });
                          showListChildAccount();
                        },
                        style: const ButtonStyle(
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                          ),
                          backgroundColor: MaterialStatePropertyAll(
                            Color.fromRGBO(248, 198, 48, 1),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline_outlined),
                            Padding(
                              padding: EdgeInsets.only(left: 6.0),
                              child: Text(
                                'Tambah Peserta',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      refresh
                          ? Column(
                              children: participantList
                                  .map<Widget>(
                                    (participant) => FilledButton(
                                      onPressed: () {
                                        participantList.remove(participant);
                                        participantIdList
                                            .remove(participant['id']);
                                        setState(() {
                                          refresh = true;
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
                                            vertical: 6.0,
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                          Color.fromRGBO(1, 98, 104, 1.0),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          participant['profile_image'] == null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              30.0)),
                                                  child: Image.asset(
                                                    'images/default_profile_image.jpg',
                                                    height: 30.0,
                                                    width: 30.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              30.0)),
                                                  child: Image.network(
                                                    'https://modis.techcreator.my.id/${participant["profile_image"]}?timestamp=${DateTime.fromMillisecondsSinceEpoch(100)}',
                                                    height: 30.0,
                                                    width: 30.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                          Container(
                                            padding: const EdgeInsets.only(
                                              left: 10.0,
                                            ),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                130,
                                            child: Text(
                                              participant['name'],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(Ionicons.md_close)
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            )
                          : Container(),
                    ],
                  ),
                )
              : Container(),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.08,
            ),
            child: FilledButton(
              onPressed: () {},
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      Color.fromRGBO(1, 98, 104, 1.0))),
              child: Text(
                widget.data == null ? 'Simpan' : 'Perbarui',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
