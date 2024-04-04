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
              onPressed: () {},
              child: const SizedBox(
                width: 60.0,
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_outlined,
                      color: Colors.black,
                    ),
                    Text(
                      'Filter',
                      style: TextStyle(
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
                        padding: const EdgeInsets.only(left: 5.0),
                        child: const RotatedBox(
                          quarterTurns: 3,
                          child: Text('Berat Badan (kg)'),
                        )),
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
                                    tooltipBorder:
                                        const BorderSide(color: Colors.black),
                                    getTooltipColor: (touchedSpot) =>
                                        Colors.white,
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: weight
                                        .filter(widget.data, '', '')
                                        .map<FlSpot>(
                                      (element) {
                                        var index = weight
                                            .filter(widget.data, '', '')
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
                                      .filter(widget.data, '', '')
                                      .length
                                      .toString(),
                                ),
                                minY: 0,
                                maxY: 100,
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
                                            .filter(widget.data, '', '')
                                            .reversed
                                            .toList();
                                        int distance =
                                            (data.length / 5).round();
                                        if (value % distance == 0 &&
                                            value < data.length) {
                                          String date =
                                              data[value.round()]['date'];
                                          date = date
                                              .split('-')
                                              .reversed
                                              .join('-');
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16.0),
                                            child: Transform.rotate(
                                              angle: 45,
                                              child: Text(
                                                date,
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
                children: weight.filter(widget.data, '', '').map<Widget>(
                  (element) {
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

                    List<String> date =
                        element['date'].split('-').reversed.toList();

                    return TileButton(
                      onPressed: () {},
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${date[0]} ${month[date[1]]} ${date[2]}',
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
