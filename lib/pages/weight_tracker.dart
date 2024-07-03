import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modis/components/alert_input_implement.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/circle_button.dart';
import 'package:modis/components/error.dart';
import 'package:modis/components/floating_action_button_modis.dart';
import 'package:modis/components/input_implement.dart';
import 'package:modis/components/tile_information_implement.dart';
import 'package:modis/providers/weight.dart';
import 'package:provider/provider.dart';

class WeightTracker extends StatefulWidget {
  const WeightTracker({
    super.key,
    required this.userEmail,
    required this.isGuide,
  });

  final String userEmail;
  final bool isGuide;

  @override
  State<WeightTracker> createState() => _WeightTrackerState();
}

class _WeightTrackerState extends State<WeightTracker> {
  int filter = 0;
  final TextEditingController addBB = TextEditingController(),
      addDateToString = TextEditingController(),
      updateBB = TextEditingController(),
      updateDateToString = TextEditingController(),
      filterValue = TextEditingController();
  final FocusNode fAddBB = FocusNode(),
      fUpdateBB = FocusNode(),
      fFilterValue = FocusNode();
  late DateTime addDate, updateDate;
  String unit = '';
  int? indexUnit = 0;
  bool isLoad = false, isError = false;

  final Map<String, String> month = {
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
    getAllData();
  }

  getAllData() {
    if (!widget.isGuide) {
      setState(() {
        isLoad = true;
        isError = false;
      });

      Provider.of<Weight>(context, listen: false)
          .getUserWeight(widget.userEmail, false)
          .then((response) {
        if (response['status'] == 'error') {
          snackbarMessenger(
            context,
            MediaQuery.of(context).size.width * 0.4,
            Colors.red,
            'Gagal terhubung server',
          );

          setState(() {
            isError = true;
          });
        } else {
          setState(() {
            isLoad = false;
          });
        }
      }).catchError((error) {
        snackbarMessenger(
          context,
          MediaQuery.of(context).size.width * 0.4,
          Colors.red,
          'Gagal terhubung server',
        );

        setState(() {
          isError = true;
        });
      });
    }
  }

  String dateToString(datetime) {
    dynamic date = datetime.toString().split(' ')[0].split('-');
    return '${date[2]} ${month[date[1]]} ${date[0]}';
  }

  void snackbarMessenger(BuildContext context, double leftPadding,
      Color backgroundColor, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.only(
          left: leftPadding,
          right: 9,
          bottom: MediaQuery.of(context).size.height * 0.7,
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

  Dialog showCalendarPicker(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime) onChanged,
  ) {
    return Dialog(
      surfaceTintColor: Colors.white,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      'Pilih Tanggal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
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
              CalendarDatePicker(
                initialDate: initialDate,
                firstDate: DateTime(1990, 1, 1),
                lastDate: DateTime.now(),
                onDateChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double maxY(List<dynamic> data) {
    if (data.isEmpty) {
      return 100.0;
    }

    dynamic max = data.reduce((value, element) =>
        double.parse(value['weight'].toString()) >
                double.parse(element['weight'].toString())
            ? value
            : element);

    return double.parse(max['weight'].toString()) + 20.0;
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
              'Lacak Berat Badan',
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
      body: isError
          ? ListView(
              children: [
                ServerErrorWidget(
                  onPressed: () {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    getAllData();
                  },
                  paddingTop: MediaQuery.of(context).size.height * 0.2,
                  label: 'Gagal memuat halaman lacak berat badan!!!',
                )
              ],
            )
          : !isLoad
              ? ListView(
                  children: [
                    const SubTitleLabel(
                      label: 'Perubahan Berat Badan',
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      alignment: Alignment.topRight,
                      child: OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              surfaceTintColor: Colors.white,
                              backgroundColor: Colors.white,
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Filter',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      Ionicons.md_close,
                                    ),
                                  ),
                                ],
                              ),
                              content: LayoutBuilder(
                                builder: (context, constraint) {
                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: constraint.maxWidth * 0.4,
                                        child: Input(
                                          textController: filterValue,
                                          label: 'Nilai',
                                          border: const OutlineInputBorder(),
                                          focusNode: fFilterValue,
                                          padding: EdgeInsets.zero,
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            filterValue.text = RegExp(
                                                    r'[-]?\d+(?:[.]\d+)?')
                                                .allMatches(filterValue.text)
                                                .map((m) => m.group(0)!)
                                                .toList()[0];
                                          },
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: constraint.maxWidth * 0.1),
                                        width: constraint.maxWidth * 0.5,
                                        child: DropdownButtonFormField(
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.all(8.0),
                                          ),
                                          value: indexUnit,
                                          items: const [
                                            DropdownMenuItem<int>(
                                              value: 0,
                                              child: Text('Tahun'),
                                            ),
                                            DropdownMenuItem<int>(
                                              value: 1,
                                              child: Text('Bulan'),
                                            ),
                                            DropdownMenuItem<int>(
                                              value: 2,
                                              child: Text('Minggu'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              indexUnit = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                                  Colors.red),
                                          shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          filterValue.text = '';
                                          setState(() {
                                            unit = '';
                                            indexUnit = 0;
                                            filter = 0;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Reset',
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
                                                      248, 198, 48, 1)),
                                          shape: MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          filter = int.parse(filterValue.text);
                                          setState(() {
                                            unit = indexUnit == 0
                                                ? 'tahun'
                                                : (indexUnit == 1
                                                    ? 'bulan'
                                                    : 'minggu');
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Filter',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
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
                        child: SizedBox(
                          width: filter != 0
                              ? double.parse(
                                  ('$filter $unit terakhir'.length * 8)
                                      .toString())
                              : 60.0,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.filter_list_outlined,
                                color: Colors.black,
                              ),
                              Text(
                                filter != 0
                                    ? '$filter $unit terakhir'
                                    : 'Filter',
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.zero,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(23, 0, 0, 0),
                            offset: Offset(0, 1),
                            blurRadius: 5.0,
                          ),
                        ],
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 350,
                      margin: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: const RotatedBox(
                                  quarterTurns: 3,
                                  child: Text('Berat Badan (kg)'),
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 30.0, right: 5.0),
                                    height: 280,
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    child: Consumer<Weight>(
                                      builder: (context, weight, child) =>
                                          LineChart(
                                        LineChartData(
                                          lineTouchData: LineTouchData(
                                            enabled: true,
                                            touchTooltipData:
                                                LineTouchTooltipData(
                                              maxContentWidth: 150,
                                              fitInsideHorizontally: true,
                                              fitInsideVertically: true,
                                              tooltipBorder: const BorderSide(
                                                  color: Colors.black),
                                              getTooltipColor: (touchedSpot) =>
                                                  Colors.white,
                                              getTooltipItems: (touchedSpots) {
                                                return touchedSpots.isNotEmpty
                                                    ? touchedSpots.map(
                                                        (LineBarSpot
                                                            touchedSpot) {
                                                        final textStyle =
                                                            TextStyle(
                                                          color: touchedSpot
                                                                  .bar
                                                                  .gradient
                                                                  ?.colors
                                                                  .first ??
                                                              touchedSpot
                                                                  .bar.color ??
                                                              Colors.blueGrey,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        );

                                                        String date =
                                                            '${weight.filter(weight.listWeightUser, filter, unit).reversed.toList()[touchedSpot.x.round()]["date"]}';
                                                        date =
                                                            dateToString(date);
                                                        String label =
                                                            '${touchedSpot.y} kg';

                                                        return LineTooltipItem(
                                                          '$date\n$label',
                                                          textStyle,
                                                        );
                                                      }).toList()
                                                    : [];
                                              },
                                            ),
                                          ),
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: weight.filter(
                                                          weight.listWeightUser,
                                                          filter,
                                                          unit) !=
                                                      null
                                                  ? weight
                                                      .filter(
                                                          weight.listWeightUser,
                                                          filter,
                                                          unit)
                                                      .map<FlSpot>(
                                                      (element) {
                                                        var index = weight
                                                            .filter(
                                                                weight
                                                                    .listWeightUser,
                                                                filter,
                                                                unit)
                                                            .reversed
                                                            .toList()
                                                            .indexOf(element);
                                                        return FlSpot(
                                                          double.parse(
                                                              index.toString()),
                                                          double.parse(
                                                            element['weight']
                                                                .toString(),
                                                          ),
                                                        );
                                                      },
                                                    ).toList()
                                                  : [],
                                              isCurved: true,
                                              color: Colors.blue,
                                              barWidth: 4,
                                              dotData:
                                                  const FlDotData(show: false),
                                            ),
                                          ],
                                          minX: 0,
                                          maxX: weight.filter(
                                                      weight.listWeightUser,
                                                      filter,
                                                      unit) !=
                                                  null
                                              ? double.parse(
                                                  weight
                                                      .filter(
                                                          weight.listWeightUser,
                                                          filter,
                                                          unit)
                                                      .length
                                                      .toString(),
                                                )
                                              : 0,
                                          minY: 0,
                                          maxY: weight.listWeightUser != null
                                              ? maxY(weight.listWeightUser)
                                              : 100,
                                          titlesData: FlTitlesData(
                                            show: true,
                                            rightTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            topTitles: const AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: false,
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 75,
                                                getTitlesWidget:
                                                    (value, titleMeta) {
                                                  dynamic data = weight.filter(
                                                              weight
                                                                  .listWeightUser,
                                                              filter,
                                                              unit) !=
                                                          null
                                                      ? weight
                                                          .filter(
                                                              weight
                                                                  .listWeightUser,
                                                              filter,
                                                              unit)
                                                          .reversed
                                                          .toList()
                                                      : [];
                                                  if (value < data.length &&
                                                      value % 1 == 0) {
                                                    String date =
                                                        data[value.round()]
                                                            ['date'];
                                                    date = date
                                                        .split('-')
                                                        .reversed
                                                        .join('-');
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 16.0,
                                                              right: 35.0),
                                                      child: Transform.rotate(
                                                        alignment:
                                                            Alignment.center,
                                                        angle: -0.45,
                                                        child: Text(
                                                          date,
                                                          textAlign:
                                                              TextAlign.start,
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  return const Text('');
                                                },
                                              ),
                                            ),
                                          ),
                                          gridData:
                                              const FlGridData(show: true),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Text('Tanggal')
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SubTitleLabel(
                      label: 'Riwayat',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      child: Consumer<Weight>(
                        builder: (context, weight, child) => Column(
                          children:
                              weight.filter(weight.listWeightUser, filter,
                                          unit) !=
                                      null
                                  ? weight
                                      .filter(
                                          weight.listWeightUser, filter, unit)
                                      .map<Widget>(
                                      (element) {
                                        return TileButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .removeCurrentSnackBar();
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
                                                          right: 8.0,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          updateBB.text =
                                                              element['weight']
                                                                  .toString();
                                                          List<String> date =
                                                              element['date']
                                                                  .toString()
                                                                  .split('-');
                                                          setState(() {
                                                            updateDate =
                                                                DateTime(
                                                              int.parse(
                                                                  date[0]),
                                                              int.parse(
                                                                  date[1]),
                                                              int.parse(
                                                                  date[2]),
                                                            );
                                                          });
                                                          updateDateToString
                                                                  .text =
                                                              dateToString(
                                                                  updateDate);
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertInput(
                                                              header: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  const SizedBox(
                                                                    width: 160,
                                                                    child: Text(
                                                                      'Perbarui Data Berat Badan',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    icon: const Icon(
                                                                        Ionicons
                                                                            .md_close),
                                                                  )
                                                                ],
                                                              ),
                                                              headerPadding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          8.0),
                                                              contents: [
                                                                Input(
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  border:
                                                                      const OutlineInputBorder(),
                                                                  textController:
                                                                      updateBB,
                                                                  focusNode:
                                                                      fUpdateBB,
                                                                  label:
                                                                      'Berat Badan',
                                                                  suffixIcon:
                                                                      const SizedBox(
                                                                    width: 10,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        'Kg',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              12.0),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.45,
                                                                        child:
                                                                            TextField(
                                                                          onTap:
                                                                              () {
                                                                            fUpdateBB.unfocus();
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (context) => StatefulBuilder(
                                                                                builder: (context, setState) => showCalendarPicker(context, updateDate, (date) {
                                                                                  Navigator.pop(context);
                                                                                  setState(() {
                                                                                    updateDate = date;
                                                                                  });
                                                                                  updateDateToString.text = dateToString(updateDate);
                                                                                }),
                                                                              ),
                                                                            );
                                                                          },
                                                                          readOnly:
                                                                              true,
                                                                          controller:
                                                                              updateDateToString,
                                                                          decoration:
                                                                              const InputDecoration(
                                                                            label:
                                                                                Text('Tanggal'),
                                                                            labelStyle:
                                                                                TextStyle(
                                                                              color: Color.fromRGBO(120, 120, 120, 1),
                                                                            ),
                                                                            border:
                                                                                OutlineInputBorder(),
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(horizontal: 8.0),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                        iconSize:
                                                                            30,
                                                                        style: const ButtonStyle(
                                                                            padding:
                                                                                MaterialStatePropertyAll(EdgeInsets.zero)),
                                                                        onPressed:
                                                                            () {
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder: (context) =>
                                                                                StatefulBuilder(
                                                                              builder: (context, setState) => showCalendarPicker(context, updateDate, (date) {
                                                                                Navigator.pop(context);
                                                                                setState(() {
                                                                                  updateDate = date;
                                                                                });
                                                                                updateDateToString.text = dateToString(updateDate);
                                                                              }),
                                                                            ),
                                                                          );
                                                                        },
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .calendar_month_outlined,
                                                                          size:
                                                                              30,
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                              contentAligment:
                                                                  'vertical',
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              actionAligment:
                                                                  'horizontal',
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
                                                                  child:
                                                                      const Text(
                                                                    'Batal',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
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
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .removeCurrentSnackBar();
                                                                    if (updateBB
                                                                            .text !=
                                                                        '') {
                                                                      loadingIndicator(
                                                                          context);
                                                                      Provider.of<Weight>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .updateWeight(
                                                                        element['id']
                                                                            .toString(),
                                                                        widget
                                                                            .userEmail,
                                                                        updateBB
                                                                            .text,
                                                                        updateDate
                                                                            .toString()
                                                                            .split(' ')[0],
                                                                        widget
                                                                            .isGuide,
                                                                      )
                                                                          .then(
                                                                              (response) {
                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator.pop(
                                                                            context);
                                                                        if (response['status'] ==
                                                                            'success') {
                                                                          snackbarMessenger(
                                                                            context,
                                                                            MediaQuery.of(context).size.width *
                                                                                0.5,
                                                                            const Color.fromARGB(
                                                                                255,
                                                                                0,
                                                                                120,
                                                                                18),
                                                                            'berhasil memperbarui berat badan',
                                                                          );
                                                                        } else {
                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.pop(
                                                                              context);
                                                                          snackbarMessenger(
                                                                            context,
                                                                            MediaQuery.of(context).size.width *
                                                                                0.5,
                                                                            Colors.red,
                                                                            response['message'],
                                                                          );

                                                                          setState(
                                                                              () {
                                                                            isError =
                                                                                true;
                                                                          });
                                                                        }
                                                                      }).catchError(
                                                                              (error) {
                                                                        snackbarMessenger(
                                                                          context,
                                                                          MediaQuery.of(context).size.width *
                                                                              0.5,
                                                                          Colors
                                                                              .red,
                                                                          'Gagal terhubung ke server',
                                                                        );
                                                                      });
                                                                    } else {
                                                                      snackbarMessenger(
                                                                        context,
                                                                        MediaQuery.of(context).size.width *
                                                                            0.5,
                                                                        Colors
                                                                            .red,
                                                                        'terdapat data yang kosong',
                                                                      );
                                                                    }
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Perbarui',
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                              actionPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8.0,
                                                                      vertical:
                                                                          12.0),
                                                            ),
                                                          );
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
                                                          left: 8.0,
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
                                                                'Apakah yakin menghapus data berat badan?',
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
                                                                        'Batal')),
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
                                                                    loadingIndicator(
                                                                        context);
                                                                    Provider.of<Weight>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .deleteWeight(
                                                                      weightId:
                                                                          element['id']
                                                                              .toString(),
                                                                      email: widget
                                                                          .userEmail,
                                                                      isGuide:
                                                                          widget
                                                                              .isGuide,
                                                                    )
                                                                        .then(
                                                                      (response) {
                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator.pop(
                                                                            context);
                                                                        snackbarMessenger(
                                                                          context,
                                                                          MediaQuery.of(context).size.width *
                                                                              0.5,
                                                                          response['status'] == 'success'
                                                                              ? const Color.fromARGB(255, 0, 120, 18)
                                                                              : Colors.red,
                                                                          response[
                                                                              'message'],
                                                                        );
                                                                      },
                                                                    ).catchError(
                                                                            (error) {
                                                                      Navigator.pop(
                                                                          context);
                                                                      Navigator.pop(
                                                                          context);
                                                                      snackbarMessenger(
                                                                        context,
                                                                        MediaQuery.of(context).size.width *
                                                                            0.5,
                                                                        Colors
                                                                            .red,
                                                                        'Gagal terhubung ke server',
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
                                          },
                                          height: 60,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                dateToString(element["date"]),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                '${element["weight"]} kg',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ).toList()
                                  : [],
                        ),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.3),
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
                ),
      floatingActionButton: FloatingActionButtonModis(onPressed: () {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        addBB.text = '';
        setState(() {
          addDate = DateTime.now();
        });
        addDateToString.text = dateToString(addDate);
        showDialog(
          context: context,
          builder: (context) => AlertInput(
            header: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: 160,
                  child: Text(
                    'Tambah Data Berat Badan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
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
            headerPadding: const EdgeInsets.only(left: 8.0),
            contents: [
              Input(
                keyboardType: TextInputType.number,
                border: const OutlineInputBorder(),
                textController: addBB,
                focusNode: fAddBB,
                label: 'Berat Badan',
                suffixIcon: const SizedBox(
                  width: 10,
                  child: Center(
                    child: Text(
                      'Kg',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: TextField(
                        onTap: () {
                          fAddBB.unfocus();
                          showDialog(
                            context: context,
                            builder: (context) => StatefulBuilder(
                              builder: (context, setState) =>
                                  showCalendarPicker(context, addDate, (date) {
                                Navigator.pop(context);
                                setState(() {
                                  addDate = date;
                                });
                                addDateToString.text = dateToString(addDate);
                              }),
                            ),
                          );
                        },
                        readOnly: true,
                        controller: addDateToString,
                        decoration: const InputDecoration(
                          label: Text('Tanggal'),
                          labelStyle: TextStyle(
                            color: Color.fromRGBO(120, 120, 120, 1),
                          ),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 30,
                      style: const ButtonStyle(
                          padding: MaterialStatePropertyAll(EdgeInsets.zero)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => StatefulBuilder(
                            builder: (context, setState) =>
                                showCalendarPicker(context, addDate, (date) {
                              Navigator.pop(context);
                              setState(() {
                                addDate = date;
                              });
                              addDateToString.text = dateToString(addDate);
                            }),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                      ),
                    )
                  ],
                ),
              )
            ],
            contentAligment: 'vertical',
            contentPadding: const EdgeInsets.all(8),
            actionAligment: 'horizontal',
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
                child: const Text(
                  'Batal',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Color.fromRGBO(1, 98, 104, 1.0),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  if (addBB.text != '') {
                    loadingIndicator(context);
                    Provider.of<Weight>(context, listen: false)
                        .addWeight(
                      widget.userEmail,
                      addBB.text,
                      addDate.toString().split(' ')[0],
                      widget.isGuide,
                    )
                        .then((response) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      if (response['status'] == 'success') {
                        snackbarMessenger(
                          context,
                          MediaQuery.of(context).size.width * 0.5,
                          const Color.fromARGB(255, 0, 120, 18),
                          'berhasil menambahkan berat badan',
                        );
                      } else {
                        snackbarMessenger(
                          context,
                          MediaQuery.of(context).size.width * 0.5,
                          Colors.red,
                          response['message'],
                        );
                      }
                    }).catchError((error) {
                      snackbarMessenger(
                        context,
                        MediaQuery.of(context).size.width * 0.5,
                        Colors.red,
                        'Gagal terhubung ke server',
                      );
                    });
                  } else {
                    snackbarMessenger(
                      context,
                      MediaQuery.of(context).size.width * 0.5,
                      Colors.red,
                      'terdapat data yang kosong',
                    );
                  }
                },
                child: const Text(
                  'Tambah',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            actionPadding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          ),
        );
      }),
    );
  }
}

class SubTitleLabel extends StatelessWidget {
  const SubTitleLabel({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(left: 10.0, top: 4.0),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'crimson',
          fontSize: 25.0,
        ),
      ),
    );
  }
}
