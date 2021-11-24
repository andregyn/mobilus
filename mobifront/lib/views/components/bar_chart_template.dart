import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobifront/models/data_value_model.dart';
import 'package:mobifront/utils/utl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';

class BarChartTemplate extends StatefulWidget {
  final List<List<DataValueModel>> series;
  final String title;
  final String subtitle;
  final double barWidth;
  final double? height;
  final bool showXlabels;

  final List<Color> availableColors = [
    Colors.blue,
    Colors.redAccent,
    Colors.green,
    Colors.purpleAccent,
    Colors.orange,
    Colors.pink,
  ];

  BarChartTemplate(
      {Key? key,
      required this.series,
      required this.title,
      this.subtitle = "",
      this.showXlabels = false,
      this.height,
      this.barWidth = 22})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => BarChartTemplateState();
}

class BarChartTemplateState extends State<BarChartTemplate> {
  final Color barBackgroundColor = const Color.fromARGB(255, 247, 248, 249);
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  bool isPlaying = false;
  double max = 0;

  @override
  Widget build(BuildContext context) {
    for (var s in widget.series) {
      double tmax = s.fold(0, (c, e) => e.value > c ? e.value : c);
      if (tmax > max) max = tmax;
    }
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.white,
        child: SizedBox(
          height: widget.height ?? 125.w,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  widget.title,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                      color: const Color(0xff379982),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: BarChart(
                      mainBarData(),
                      swapAnimationDuration: animDuration,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x, {
    bool isTouched = false,
    Color barColor = Colors.blue,
    List<int> showTooltips = const [],
  }) {
    for (var s in widget.series) {
      double tmax = s.fold(0, (c, e) => e.value > c ? e.value : c);
      if (tmax > max) max = tmax;
    }

    List<BarChartRodData> rods = [];
    for (int ix = 0; ix < widget.series.length; ix++) {
      DataValueModel o = (x < widget.series[ix].length)
          ? widget.series[ix][x]
          : DataValueModel();
      rods.add(BarChartRodData(
        y: o.value,
        colors: isTouched
            ? [Colors.blueAccent]
            : [widget.series[ix][x].color ?? barColor],
        width: widget.barWidth,
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          y: 20,
          colors: [barBackgroundColor],
        ),
      ));
    }

    return BarChartGroupData(
      x: x,
      barRods: rods,
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() =>
      List.generate(widget.series.first.length, (i) {
        return makeGroupData(i,
            isTouched: i == touchedIndex,
            barColor: widget.availableColors[i % 6]);
      });

  BarChartData mainBarData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.grey.shade100,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                  widget.series[rodIndex][groupIndex].data +
                      '\n' +
                      (Utl.brNumber(rod.y)).toString(),
                  const TextStyle(color: Colors.black87));
            }),
        touchCallback: (touchEvent, barTouchResponse) {
          setState(() {
            touchedIndex = barTouchResponse?.spot?.touchedBarGroupIndex ?? -1;
          });
        },
      ),
      titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
              showTitles: true,
              getTextStyles: (context, value) => const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
              margin: 16,
              getTitles: (double value) {
                if (widget.showXlabels) {
                  return widget.series[0][value.toInt()].data;
                }
                return "";
              }),
          leftTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              //interval: Utl.getRoundedInterval(max / 5),
              checkToShowTitle: (serie, vmax, tile, interval, step) {
                double nsteps =
                    (((vmax / interval.truncate()).truncate() + 1).truncate() /
                            5)
                        .truncateToDouble();
                return step == 0 || step % (nsteps * interval) == 0;
              },
              getTitles: (value) {
                var f = NumberFormat.compact();
                return f.format(value);
              })),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
    );
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
        animDuration + const Duration(milliseconds: 50));
    if (isPlaying) {
      refreshState();
    }
  }
}
