import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/input_implement.dart';
import 'package:modis/components/outline_button_implement.dart';
import 'package:modis/providers/events.dart';
import 'package:provider/provider.dart';

class CreateEditEvent extends StatefulWidget {
  const CreateEditEvent({super.key, this.data});
  final dynamic data;

  @override
  State<CreateEditEvent> createState() => _CreateEditEventState();
}

class _CreateEditEventState extends State<CreateEditEvent> {
  final TextEditingController eventName = TextEditingController(),
      date = TextEditingController(),
      startTime = TextEditingController(),
      endTime = TextEditingController(),
      contactPerson = TextEditingController(),
      location = TextEditingController(),
      coordinateLocation = TextEditingController();
  List<dynamic> eventType = [
    {'index': '0', 'type': 'Offline'},
    {'index': '1', 'type': 'Online'},
    {'index': '2', 'type': 'Hybrid'}
  ];
  String? eventDate, eventStartTime, eventEndTime;
  final FocusNode fEventName = FocusNode(),
      fDate = FocusNode(),
      fStartTime = FocusNode(),
      fEndTIme = FocusNode(),
      fContactPerson = FocusNode(),
      fLocation = FocusNode(),
      fCoordinateLocation = FocusNode();
  int? eventIndex;
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
  bool needLocation = false;
  final ImagePicker picker = ImagePicker();
  File? eventPoster;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {}
  }

  convertDateToString(String date) {
    List splitDate = date.split(' ')[0].split('-');
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
              'Buat Event Baru',
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
              focusNode: fEventName,
              textController: eventName,
              label: 'Nama Event',
              border: const OutlineInputBorder(),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Input(
              textController: date,
              focusNode: fDate,
              label: 'Tanggal Pelaksanaan',
              readonly: true,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Ionicons.md_calendar),
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
                          initialDate: eventDate == null
                              ? DateTime(DateTime.now().year,
                                  DateTime.now().month, DateTime.now().day + 1)
                              : DateTime(
                                  int.parse(eventDate!.split('-')[0]),
                                  int.parse(eventDate!.split('-')[1]),
                                  int.parse(eventDate!.split('-')[2])),
                          firstDate: DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day + 1),
                          lastDate: DateTime(2100),
                          onDateChanged: (selectedDate) {
                            date.text =
                                convertDateToString(selectedDate.toString());
                            setState(() {
                              eventDate = selectedDate.toString().split(' ')[0];
                            });
                            Navigator.pop(context);
                          }),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Input(
              textController: startTime,
              label: 'Waktu Mulai',
              focusNode: fStartTime,
              border: const OutlineInputBorder(),
              readonly: true,
              suffixIcon: const Icon(Ionicons.md_time),
              onTap: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                showDialog(
                    context: context,
                    builder: (context) => TimePickerDialog(
                          helpText: 'Pilih Waktu Mulai',
                          confirmText: 'Simpan',
                          cancelText: 'Batal',
                          initialTime: TimeOfDay.now(),
                        )).then((selectedTime) {
                  if (selectedTime != null) {
                    String time =
                        '${selectedTime.hour.toString().length > 1 ? selectedTime.hour : "0${selectedTime.hour}"}:${selectedTime.minute.toString().length > 1 ? selectedTime.minute : "0${selectedTime.minute}"}';
                    startTime.text = time;
                    setState(() {
                      eventStartTime = time;
                    });
                  }
                  fStartTime.unfocus();
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: Input(
              textController: endTime,
              label: 'Waktu Selesai',
              focusNode: fEndTIme,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Ionicons.md_time),
              readonly: true,
              onTap: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                showDialog(
                    context: context,
                    builder: (context) => TimePickerDialog(
                          helpText: 'Pilih Waktu Selesai',
                          confirmText: 'Simpan',
                          cancelText: 'Batal',
                          initialTime: TimeOfDay.now(),
                        )).then((selectedTime) {
                  if (selectedTime != null) {
                    String time =
                        '${selectedTime.hour.toString().length > 1 ? selectedTime.hour : "0${selectedTime.hour}"}:${selectedTime.minute.toString().length > 1 ? selectedTime.minute : "0${selectedTime.minute}"}';
                    endTime.text = time;
                    setState(() {
                      eventEndTime = time;
                    });
                  }
                  fStartTime.unfocus();
                });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: Input(
              textController: contactPerson,
              label: 'Contact Person',
              focusNode: fContactPerson,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
              keyboardType: TextInputType.phone,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 18.0,
              left: MediaQuery.of(context).size.width * 0.05,
              right: MediaQuery.of(context).size.width * 0.05,
            ),
            width: MediaQuery.of(context).size.width * 0.9,
            child: DropdownButtonFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8.0),
              ),
              value: eventIndex,
              hint: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.event,
                      color: Color.fromRGBO(120, 120, 120, 1),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Text('Pilih Jenis Event'),
                  ),
                ],
              ),
              items: eventType
                  .map<DropdownMenuItem<int>>(
                    (type) => DropdownMenuItem<int>(
                      value: int.parse(type['index']),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.event,
                              color: Color.fromRGBO(120, 120, 120, 1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(type['type']),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  eventIndex = value;
                  if (eventType[value!]['type'] != 'Online') {
                    needLocation = true;
                  } else {
                    needLocation = false;
                  }
                });
              },
            ),
          ),
          needLocation
              ? Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                      ),
                      child: Input(
                        textController: location,
                        label: 'Lokasi Event',
                        focusNode: fLocation,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                      ),
                      child: Input(
                        textController: coordinateLocation,
                        label: 'Titik Koordinat Lokasi Event',
                        focusNode: fCoordinateLocation,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                )
              : Container(),
          OutlinedButtonModis(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              radius: 4.0,
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
                top: 20.0,
              ),
              childrens: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: const Text(
                    'Poster Event',
                    style: TextStyle(
                      color: Color.fromRGBO(120, 120, 120, 1),
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
              onPressed: () {
                picker
                    .pickImage(source: ImageSource.gallery)
                    .then((selectedImage) {
                  if (selectedImage != null) {
                    setState(() {
                      eventPoster = File(selectedImage.path);
                    });
                  }
                });
              }),
          eventPoster != null
              ? Container(
                  margin: EdgeInsets.only(
                    top: 6.0,
                    left: MediaQuery.of(context).size.width * 0.05,
                    right: MediaQuery.of(context).size.width * 0.05,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preview:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.file(eventPoster!),
                    ],
                  ),
                )
              : Container(),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.2,
                vertical: 18.0),
            child: FilledButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Color.fromRGBO(1, 98, 104, 1.0),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                if (eventName.text == '' ||
                    eventDate == null ||
                    eventStartTime == null ||
                    eventEndTime == '' ||
                    eventIndex == null) {
                  snackbarMessenger(
                    context,
                    MediaQuery.of(context).size.width * 0.35,
                    Colors.red,
                    'Terdapat data yang belum terisi!!!',
                    MediaQuery.of(context).size.height * 0.72,
                  );
                } else if (eventType[eventIndex!]['type'] != 'Online' &&
                    (location.text == '' || coordinateLocation.text == '')) {
                  snackbarMessenger(
                    context,
                    MediaQuery.of(context).size.width * 0.35,
                    Colors.red,
                    'Data lokasi yang belum terisi!!!',
                    MediaQuery.of(context).size.height * 0.72,
                  );
                } else if (int.parse(eventStartTime!.split(':')[0]) >
                        int.parse(eventEndTime!.split(':')[0]) ||
                    (int.parse(eventStartTime!.split(':')[0]) ==
                            int.parse(eventEndTime!.split(':')[0]) &&
                        int.parse(eventStartTime!.split(':')[1]) >
                            int.parse(eventEndTime!.split(':')[1]))) {
                  snackbarMessenger(
                    context,
                    MediaQuery.of(context).size.width * 0.35,
                    Colors.red,
                    'Waktu Mulai Harus Sebelum Waktu selesai',
                    MediaQuery.of(context).size.height * 0.72,
                  );
                } else {
                  loadingIndicator(context);
                  if (widget.data == null) {
                    Provider.of<EventsForDilans>(context, listen: false)
                        .addEvent(
                      eventName.text,
                      eventPoster,
                      eventType[eventIndex!]['type'],
                      eventDate!,
                      eventStartTime!,
                      eventEndTime!,
                      contactPerson.text,
                      location.text,
                      coordinateLocation.text,
                    )
                        .then((response) {
                      Navigator.pop(context);
                      if (response['status'] == 'success') {
                        Navigator.pop(context, true);
                        snackbarMessenger(
                          context,
                          MediaQuery.of(context).size.width * 0.35,
                          const Color.fromARGB(255, 0, 120, 18),
                          'berhasil mengunggah video',
                          MediaQuery.of(context).size.height * 0.6,
                        );
                      } else {
                        snackbarMessenger(
                          context,
                          MediaQuery.of(context).size.width * 0.35,
                          Colors.red,
                          'gagal terhubung ke server',
                          MediaQuery.of(context).size.height * 0.72,
                        );
                      }
                    }).catchError((error) {
                      Navigator.pop(context, true);
                      snackbarMessenger(
                        context,
                        MediaQuery.of(context).size.width * 0.35,
                        Colors.red,
                        'gagal terhubung ke server',
                        MediaQuery.of(context).size.height * 0.72,
                      );
                    });
                  } else {
                    Provider.of<EventsForDilans>(context, listen: false)
                        .updateEvent();
                  }
                }
              },
              child: const Text(
                'Simpan',
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
