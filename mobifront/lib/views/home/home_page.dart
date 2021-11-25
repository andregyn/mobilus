import 'package:flutter/material.dart';
import 'package:mobifront/utils/utl.dart';
import 'package:mobifront/views/components/line_chart_template.dart';
import 'package:mobifront/views/components/my_error_container.dart';
import 'package:mobifront/views/components/my_waitfor_info.dart';
import 'package:mobifront/views/home/home_controller.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../components/my_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = HomeController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => loadData());
  }

  Future<void> loadData() async {
    setState(() {
      controller.lastError = "";
      controller.sampleCases = null;
    });
    Future.delayed(Duration.zero, () async {
      await controller.getLatestSixMonths();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        title: "Covid 19",
        onRefresh: loadData,
        child: Semantics(
          label: "Mobilus Covid 19",
          child: controller.lastError.isNotEmpty
              ? MyErrorContainer(error: controller.lastError, retry: loadData)
              : controller.sampleCases == null
                  ? const MyWaitforInfo(title: "Carregando informações...")
                  : Padding(
                      padding:
                          EdgeInsets.only(left: 5.w, right: 5.w, top: 32.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Casos",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!),
                                      Text(
                                          Utl.intNumber(controller
                                              .sampleCases!.last.total
                                              .toDouble()),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6),
                                      Text(
                                          "+" +
                                              Utl.intNumber(controller
                                                  .sampleCases!.last.cases
                                                  .toDouble()),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .apply(color: Colors.black54)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 50,
                                    child: VerticalDivider(
                                      width: 1,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Mortes",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!),
                                      Text(
                                          Utl.intNumber(controller
                                              .sampleDeaths!.last.total
                                              .toDouble()),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6),
                                      Text(
                                          "+" +
                                              Utl.intNumber(controller
                                                  .sampleDeaths!.last.cases
                                                  .toDouble()),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .apply(color: Colors.black54)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Evolução dos casos de Covid-19 no Brasil nos últimos 6 meses",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                height: 30.h,
                                width: 100.w - 32,
                                child: LineChartTemplate(
                                  toolTipText: (element) {
                                    return ((element.barIndex == 0)
                                            ? controller
                                                    .cases[element.spotIndex]
                                                    .data +
                                                "\n"
                                            : "") +
                                        "${Utl.brQty(element.y)} " +
                                        (element.barIndex == 0
                                            ? " casos"
                                            : "mortes");
                                  },
                                  height: 120,
                                  series: [controller.cases, controller.deaths],
                                  title: "",
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 32, left: 8.0, right: 8, bottom: 16),
                              child: Text(
                                "Média móvel nos últimos 14 dias",
                                style: Theme.of(context).textTheme.headline6,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(
                              height: 30.h,
                              child: LineChartTemplate(
                                toolTipText: (element) {
                                  return ((element.barIndex == 0)
                                          ? controller.cases[element.spotIndex]
                                                  .data +
                                              "\n"
                                          : "") +
                                      ((element.barIndex == 0)
                                          ? "Média: ${Utl.intNumber(element.y)} "
                                          : "Casos: ${Utl.intNumber(element.y)} ");
                                },
                                height: 120,
                                series: [controller.mobile, controller.daily],
                                title: "",
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      bool called= false;
                                      bool ok = false;
                                      await Utl.execProgress(context, "Obtendo dados...", async () { 
                                        if (!called) { 
                                      ok = await controller.getTopMost();

                                        }

                                      });
                                      Navigator.pushNamed(context, "/details",
                                          arguments: controller);
                                    },
                                    child: const Text(
                                        "Ver piores dias no último mês...")),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, "/details",
                                          arguments: controller);
                                    },
                                    child: const Text("Ver detalhes..."))
                              ],
                            ),
                            SizedBox(height: 50.h)
                          ]),
                    ),
        ));
  }
}
