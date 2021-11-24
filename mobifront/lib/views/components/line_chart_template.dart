import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobifront/models/data_value_model.dart';
import 'package:mobifront/utils/utl.dart';
import 'package:intl/intl.dart';

class LineChartTemplate extends StatefulWidget {
  final List<List<DataValueModel>> series;
  final String title;
  final double? height;
  final bool? showAxisLabel;
  final String subtitle;
  final Widget? footer;
  final String Function(LineBarSpot spot)? toolTipText;

  LineChartTemplate(
      {Key? key,
      required this.series,
      required this.title,
      this.footer,
      this.toolTipText,
      this.height,
      this.showAxisLabel,
      this.subtitle = ""})
      : super(key: key);

  final List<Color> availableColors = [
    Colors.blue,
    Colors.purpleAccent,
    Colors.green,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
  ];
  @override
  State<StatefulWidget> createState() => LineChartTemplateState();
}

class LineChartTemplateState extends State<LineChartTemplate> {
  bool isShowingMainData = true;

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white38,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.title.isNotEmpty)
              Text(
                widget.title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
                textAlign: TextAlign.center,
              ),
            if (widget.subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: LineChart(
                getData(),
                swapAnimationDuration: const Duration(milliseconds: 250),
              ),
            ),
            if (widget.footer != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: widget.footer!),
              )
          ],
        ));
  }

  LineChartData getData() {
    double max = 0;
    for (var s in widget.series) {
      double tmax = s.reduce((c, n) => n.value > c.value ? n : c).value;
      if (tmax > max) max = tmax;
    }

    double ninterval = Utl.getRoundedInterval(max / 8);
    if (ninterval <= 0) ninterval = 1;
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.shade50.withOpacity(0.8),
            getTooltipItems: (spots) {
              bool first = true;
              return spots.map((element) {
                var r = LineTooltipItem(
                    widget.toolTipText == null
                        ? (first
                                ? (widget
                                        .series[element.barIndex]
                                            [element.spotIndex]
                                        .data +
                                    '\n')
                                : "") +
                            (Utl.brNumber(element.y)).toString()
                        : widget.toolTipText!(element),
                    const TextStyle(color: Colors.black87));
                first = false;
                return r;
              }).toList();
            }),
        touchCallback: (touchEvent, touchResponse) {},
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: ninterval,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTextStyles: (context, value) => const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            margin: 10,
            getTitles: (value) {
              return widget.series[0].length > value
                  ? ((widget.showAxisLabel ?? true)
                      ? widget.series[0][value.toInt()].data
                      : "")
                  : "";
            },
          ),
          rightTitles: SideTitles(showTitles: false),
          topTitles: SideTitles(showTitles: false),
          leftTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: ninterval,
              checkToShowTitle: (serie, vmax, tile, interval, step) {
                // double nsteps =
                //     (((vmax / interval.truncate()).truncate() + 1).truncate() /
                //             5)
                //         .truncateToDouble();
                // return step == 0 || step % (nsteps * interval) == 0;
                return step == 0 || (step * interval) % (ninterval) == 0;
              },
              getTitles: (value) {
                var f = NumberFormat.compact();
                return f.format(value);
              })),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade50,
            width: 4,
          ),
          left: const BorderSide(
            color: Colors.transparent,
          ),
          right: const BorderSide(
            color: Colors.transparent,
          ),
          top: const BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      minX: 0,
      maxX: widget.series[0].length.toDouble(),
      maxY: max,
      minY: 0,
      lineBarsData: widget.series.map((e) {
        double pos = 0;
        var aspot = e.map((x) => FlSpot(pos++, x.value)).toList();

        return LineChartBarData(
          spots: aspot,
          isCurved: true,
          colors: [
            widget.series[widget.series.indexOf(e)].first.color ??
                widget.availableColors[widget.series.indexOf(e)],
          ],
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: widget.series[widget.series.indexOf(e)].first.area ?? false,
            colors: [
              widget.series[widget.series.indexOf(e)].first.color
                      ?.withOpacity(0.5) ??
                  widget.availableColors[widget.series.indexOf(e)]
                      .withOpacity(0.5),
            ],
          ),
        );
      }).toList(),
    );
  }
}
