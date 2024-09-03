import 'dart:math';

import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/input_implement.dart';
import 'package:modis/components/outline_button_implement.dart';
import 'package:modis/components/tab_button.dart';

class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  bool isBMICalculate = true;
  final TextEditingController tb = TextEditingController(),
      bb = TextEditingController(),
      age = TextEditingController();
  final FocusNode ftb = FocusNode(), fbb = FocusNode(), fage = FocusNode();
  int? gender, activity;

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
              'Kalkulator Kesehatan',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
        header: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TabButton(
                    isActive: isBMICalculate,
                    onPressed: () {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ftb.unfocus();
                      fbb.unfocus();
                      fage.unfocus();
                      tb.text = '';
                      bb.text = '';
                      age.text = '';
                      setState(() {
                        gender = null;
                        activity = null;
                        isBMICalculate = true;
                      });
                    },
                    label: 'BMI',
                  ),
                  TabButton(
                    isActive: !isBMICalculate,
                    onPressed: () {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ftb.unfocus();
                      fbb.unfocus();
                      fage.unfocus();
                      tb.text = '';
                      bb.text = '';
                      age.text = '';
                      setState(() {
                        gender = null;
                        activity = null;
                        isBMICalculate = false;
                      });
                    },
                    label: 'Kebutuhan Kalori',
                  ),
                ],
              ),
            ],
          ),
        ),
        paddingHeader: 2.3,
      ),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 11.0, left: 12.0, right: 12.0),
            child: Text(
              isBMICalculate ? 'Kalkulator BMI' : 'Kalkulator Kebutuhan Kalori',
              style: const TextStyle(
                fontFamily: 'crimson',
                fontSize: 25,
              ),
            ),
          ),
          Column(
            children: isBMICalculate
                ? [
                    Input(
                      textController: tb,
                      focusNode: ftb,
                      keyboardType: TextInputType.number,
                      label: 'Tinggi Badan (cm)',
                      border: const OutlineInputBorder(),
                      width: MediaQuery.of(context).size.width * 0.9,
                      onChanged: (value) {
                        tb.text = tb.text.replaceAll(RegExp(r'[^0-9.]'), '');

                        if (RegExp(r'\.').allMatches(tb.text).length > 1) {
                          tb.text = tb.text.substring(0, tb.text.length - 1);
                        }
                      },
                    ),
                    Input(
                      textController: bb,
                      focusNode: fbb,
                      keyboardType: TextInputType.number,
                      label: 'Berat Badan (kg)',
                      border: const OutlineInputBorder(),
                      width: MediaQuery.of(context).size.width * 0.9,
                      onChanged: (value) {
                        bb.text = bb.text.replaceAll(RegExp(r'[^0-9.]'), '');

                        if (RegExp(r'\.').allMatches(bb.text).length > 1) {
                          bb.text = bb.text.substring(0, bb.text.length - 1);
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButtonModis(
                            childrens: const [
                              Text(
                                'Hitung',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ftb.unfocus();
                              fbb.unfocus();
                              if (RegExp(r'[^0-9.]').hasMatch(tb.text) ||
                                  RegExp(r'[^0-9.]').hasMatch(bb.text)) {
                                snackbarMessenger(
                                  context,
                                  MediaQuery.of(context).size.width * 0.5,
                                  Colors.red,
                                  'Nilai yang dimasukkan hanya berupa angka dan tanda titik (.) untuk bilangan tesimal',
                                );
                              } else if (tb.text != '' &&
                                  tb.text != '0' &&
                                  bb.text != '' &&
                                  bb.text != '0') {
                                double valueBb = double.parse(bb.text);
                                double valueTb = double.parse(tb.text) / 100;
                                double resultBmi = valueBb / (pow(valueTb, 2));
                                String bmi = resultBmi.toStringAsFixed(2);
                                String category = '';
                                Color categoryColor = Colors.black;

                                if (resultBmi < 18.5) {
                                  category = 'Kurang';
                                  categoryColor =
                                      const Color.fromARGB(255, 158, 118, 0);
                                } else if (resultBmi < 25.0) {
                                  category = 'Normal';
                                  categoryColor =
                                      const Color.fromARGB(255, 0, 120, 4);
                                } else if (resultBmi < 30) {
                                  category = 'Berlebih';
                                  categoryColor =
                                      const Color.fromARGB(255, 219, 80, 0);
                                } else {
                                  category = 'Obesitas';
                                  categoryColor =
                                      const Color.fromARGB(255, 171, 0, 0);
                                }

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                      'Hasil Perhitungan BMI',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    content: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.3,
                                      child: Column(
                                        children: [
                                          Icon(
                                            Ionicons.md_calculator,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.2,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0),
                                            child: Text(
                                              bmi,
                                              style: TextStyle(
                                                  color: categoryColor,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            category,
                                            style: TextStyle(
                                                color: categoryColor,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    surfaceTintColor: Colors.white,
                                    backgroundColor: Colors.white,
                                  ),
                                );
                              } else if (tb.text == '' || bb.text == '') {
                                snackbarMessenger(
                                  context,
                                  MediaQuery.of(context).size.width * 0.5,
                                  Colors.red,
                                  tb.text == ''
                                      ? 'Tinggi badan harus diisi!'
                                      : 'Berat badan harus diisi!',
                                );
                              } else if (tb.text == '0') {
                                snackbarMessenger(
                                  context,
                                  MediaQuery.of(context).size.width * 0.5,
                                  Colors.red,
                                  'Tinggi badan tidak boleh bernilai 0',
                                );
                              }
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10.0),
                            child: OutlinedButtonModis(
                                childrens: const [
                                  Text(
                                    'Ulang',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                                onPressed: () {
                                  tb.text = '';
                                  bb.text = '';
                                  ftb.unfocus();
                                  fbb.unfocus();
                                }),
                          ),
                        ],
                      ),
                    ),
                  ]
                : [
                    Container(
                      margin: const EdgeInsets.only(top: 22.0),
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                        value: gender,
                        hint: const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.attribution,
                                color: Color.fromRGBO(120, 120, 120, 1),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Text('Pilih Jenis Kelamin'),
                            ),
                          ],
                        ),
                        items: const [
                          DropdownMenuItem<int>(
                            value: 0,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.female,
                                    color: Color.fromRGBO(120, 120, 120, 1),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: Text('Perempuan'),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem<int>(
                            value: 1,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.male,
                                    color: Color.fromRGBO(120, 120, 120, 1),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: Text('Pria'),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          gender = value;
                        },
                      ),
                    ),
                    Input(
                      textController: tb,
                      focusNode: ftb,
                      keyboardType: TextInputType.number,
                      label: 'Tinggi Badan (cm)',
                      border: const OutlineInputBorder(),
                      width: MediaQuery.of(context).size.width * 0.9,
                      onChanged: (value) {
                        tb.text = tb.text.replaceAll(RegExp(r'[^0-9.]'), '');

                        if (RegExp(r'\.').allMatches(tb.text).length > 1) {
                          tb.text = tb.text.substring(0, tb.text.length - 1);
                        }
                      },
                    ),
                    Input(
                      textController: bb,
                      focusNode: fbb,
                      keyboardType: TextInputType.number,
                      label: 'Berat Badan (kg)',
                      border: const OutlineInputBorder(),
                      width: MediaQuery.of(context).size.width * 0.9,
                      onChanged: (value) {
                        bb.text = bb.text.replaceAll(RegExp(r'[^0-9.]'), '');

                        if (RegExp(r'\.').allMatches(bb.text).length > 1) {
                          bb.text = bb.text.substring(0, bb.text.length - 1);
                        }
                      },
                    ),
                    Input(
                      textController: age,
                      focusNode: fage,
                      keyboardType: TextInputType.number,
                      label: 'Usia',
                      border: const OutlineInputBorder(),
                      width: MediaQuery.of(context).size.width * 0.9,
                      onChanged: (value) {
                        age.text = age.text.replaceAll(RegExp(r'[^0-9.]'), '');

                        if (RegExp(r'\.').allMatches(age.text).isNotEmpty) {
                          age.text = age.text.substring(0, age.text.length - 1);
                        }
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: DropdownButtonFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                        value: activity,
                        hint: const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.event_sharp,
                                color: Color.fromRGBO(120, 120, 120, 1),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Text('Pilih Jenis Aktivitas'),
                            ),
                          ],
                        ),
                        items: const [
                          DropdownMenuItem<int>(
                            value: 0,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.event_sharp,
                                    color: Color.fromRGBO(120, 120, 120, 1),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: Text('Tidak Aktif'),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem<int>(
                            value: 1,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.event_sharp,
                                    color: Color.fromRGBO(120, 120, 120, 1),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: Text('Sedikit Aktif'),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem<int>(
                            value: 2,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.event_sharp,
                                    color: Color.fromRGBO(120, 120, 120, 1),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: Text('Aktif'),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem<int>(
                            value: 3,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.event_sharp,
                                    color: Color.fromRGBO(120, 120, 120, 1),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: Text('Sangat Aktif'),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem<int>(
                            value: 4,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.event_sharp,
                                    color: Color.fromRGBO(120, 120, 120, 1),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 15.0),
                                  child: Text('Sangat Aktif Secara Fisik'),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          activity = value;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButtonModis(
                            childrens: const [
                              Text(
                                'Hitung',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                              ftb.unfocus();
                              fbb.unfocus();
                              fage.unfocus();
                              if (gender == null ||
                                  activity == null ||
                                  tb.text == '' ||
                                  bb.text == '' ||
                                  age.text == '') {
                                snackbarMessenger(
                                  context,
                                  MediaQuery.of(context).size.width * 0.38,
                                  Colors.red,
                                  gender == null
                                      ? 'Jenis kelamin harus dipilih'
                                      : (tb.text == ''
                                          ? 'Tinggi badan harus diisi'
                                          : (bb.text == ''
                                              ? 'Berat badan harus diisi'
                                              : (age.text == ''
                                                  ? 'Usia harus diisi'
                                                  : 'Jenis aktivitas harus dipilih'))),
                                );
                              } else if (RegExp(r'[^0-9.]').hasMatch(tb.text) ||
                                  RegExp(r'[^0-9.]').hasMatch(bb.text) ||
                                  RegExp(r'[^0-9.]').hasMatch(age.text)) {
                                snackbarMessenger(
                                  context,
                                  MediaQuery.of(context).size.width * 0.5,
                                  Colors.red,
                                  'Nilai yang dimasukkan hanya berupa angka dan tanda titik (.) untuk bilangan tesimal',
                                );
                              } else {
                                double calorieResult = 0;
                                double activityFactor = activity == 0
                                    ? 1.2
                                    : (activity == 1
                                        ? 1.375
                                        : (activity == 2
                                            ? 1.55
                                            : activity == 3
                                                ? 1.725
                                                : 1.9));
                                if (gender == 0) {
                                  calorieResult = (10 * double.parse(bb.text) +
                                          6.25 * double.parse(tb.text) -
                                          5 * double.parse(age.text) -
                                          161) *
                                      activityFactor;
                                } else {
                                  calorieResult = (10 * double.parse(bb.text) +
                                          6.25 * double.parse(tb.text) -
                                          5 * double.parse(age.text) +
                                          5) *
                                      activityFactor;
                                }

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                      'Hasil Perhitungan Kebutuhan Kalori',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    content: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.35,
                                      child: Column(
                                        children: [
                                          Icon(
                                            Ionicons.md_calculator,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.2,
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 12.0),
                                            child: Text(
                                              'Anda Membutuhkan',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            '${calorieResult.toStringAsFixed(2)} Kalori/Hari',
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    surfaceTintColor: Colors.white,
                                    backgroundColor: Colors.white,
                                  ),
                                );
                              }
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10.0),
                            child: OutlinedButtonModis(
                                childrens: const [
                                  Text(
                                    'Ulang',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                                onPressed: () {
                                  tb.text = '';
                                  bb.text = '';
                                  age.text = '';
                                  ftb.unfocus();
                                  fbb.unfocus();
                                  fage.unfocus();
                                }),
                          ),
                        ],
                      ),
                    ),
                  ],
          )
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
