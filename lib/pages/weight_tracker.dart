import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:modis/components/app_bar_implement.dart';
import 'package:modis/components/floating_action_button_modis.dart';
import 'package:modis/components/tile_information_implement.dart';
import 'package:modis/providers/weight.dart';
import 'package:provider/provider.dart';

class WeightTracker extends StatefulWidget {
  const WeightTracker({
    super.key,
    required this.data,
    required this.isGuide,
  });

  final dynamic data;
  final bool isGuide;

  @override
  State<WeightTracker> createState() => _WeightTrackerState();
}

class _WeightTrackerState extends State<WeightTracker> {
  int? filter;

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

  String dateToString(datetime) {
    dynamic date = datetime.toString().split(' ')[0].split('-');
    return '${date[2]} ${month[date[1]]} ${date[0]}';
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
      body: ListView(
        children: [
          const SubTitleLabel(
            label: 'Perubahan Berat Badan',
          ),
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            alignment: Alignment.topRight,
            child: OutlinedButton(
              onPressed: () {
                showMenu(
                  context: context,
                  color: Colors.white,
                  position: RelativeRect.fromDirectional(
                    textDirection: TextDirection.ltr,
                    start: 1.0,
                    top: 145,
                    end: 0,
                    bottom: 0,
                  ),
                  items: [
                    PopupMenuItem(
                      onTap: () {
                        setState(() {
                          filter = null;
                        });
                      },
                      child: const Text('Reset Filter'),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        setState(() {
                          filter = 23;
                        });
                      },
                      child: const Text('2 Tahun Terakhir'),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        setState(() {
                          filter = 11;
                        });
                      },
                      child: const Text('1 Tahun Terakhir'),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        setState(() {
                          filter = 5;
                        });
                      },
                      child: const Text('6 Bulan Terakhir'),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        setState(() {
                          filter = 2;
                        });
                      },
                      child: const Text('3 Bulan Terakhir'),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        setState(() {
                          filter = 1;
                        });
                      },
                      child: const Text('2 Bulan Terakhir'),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        setState(() {
                          filter = 0;
                        });
                      },
                      child: const Text('1 Bulan Terakhir'),
                    ),
                  ],
                );
              },
              child: SizedBox(
                width: filter == null ? 60.0 : 125.0,
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list_outlined,
                      color: Colors.black,
                    ),
                    Text(
                      filter != null
                          ? (filter! < 11
                              ? '$filter bulan terakhir'
                              : (filter! == 11
                                  ? '1 tahun terakhir'
                                  : '2 tahun terakhir'))
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
                          margin: const EdgeInsets.only(top: 30.0, right: 5.0),
                          height: 280,
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: Consumer<Weight>(
                            builder: (context, weight, child) => LineChart(
                              LineChartData(
                                lineTouchData: LineTouchData(
                                  enabled: true,
                                  touchTooltipData: LineTouchTooltipData(
                                    maxContentWidth: 150,
                                    fitInsideHorizontally: true,
                                    tooltipBorder:
                                        const BorderSide(color: Colors.black),
                                    getTooltipColor: (touchedSpot) =>
                                        Colors.white,
                                    getTooltipItems: (touchedSpots) {
                                      return touchedSpots
                                          .map((LineBarSpot touchedSpot) {
                                        final textStyle = TextStyle(
                                          color: touchedSpot
                                                  .bar.gradient?.colors.first ??
                                              touchedSpot.bar.color ??
                                              Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        );

                                        String date =
                                            '${weight.filter(weight.listWeightBasedGuide, filter).reversed.toList()[touchedSpot.x.round()]["date"]}';
                                        date = dateToString(date);
                                        String label = '${touchedSpot.y} kg';

                                        return LineTooltipItem(
                                          '$date\n$label',
                                          textStyle,
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: weight
                                        .filter(widget.data, filter)
                                        .map<FlSpot>(
                                      (element) {
                                        var index = weight
                                            .filter(widget.data, filter)
                                            .reversed
                                            .toList()
                                            .indexOf(element);
                                        return FlSpot(
                                          double.parse(index.toString()),
                                          double.parse(
                                            element['weight'].toString(),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                    isCurved: true,
                                    color: Colors.blue,
                                    barWidth: 4,
                                    dotData: const FlDotData(show: false),
                                  ),
                                ],
                                minX: 0,
                                maxX: double.parse(
                                  weight
                                      .filter(widget.data, filter)
                                      .length
                                      .toString(),
                                ),
                                minY: 0,
                                maxY: 120,
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
                                      getTitlesWidget: (value, titleMeta) {
                                        dynamic data = weight
                                            .filter(widget.data, filter)
                                            .reversed
                                            .toList();
                                        if (value < data.length &&
                                            value % 1 == 0) {
                                          String date =
                                              data[value.round()]['date'];
                                          date = date
                                              .split('-')
                                              .reversed
                                              .join('-');
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16.0, right: 35.0),
                                            child: Transform.rotate(
                                              alignment: Alignment.center,
                                              angle: -0.45,
                                              child: Text(
                                                date,
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                          );
                                        }

                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                                gridData: const FlGridData(show: true),
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
                children: weight.filter(widget.data, filter).map<Widget>(
                  (element) {
                    return TileButton(
                      onPressed: () {},
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateToString(element["date"]),
                            style: const TextStyle(color: Colors.black),
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
                ).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButtonModis(onPressed: () {}),
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
