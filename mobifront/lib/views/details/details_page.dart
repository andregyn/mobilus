import 'package:flutter/material.dart';
import 'package:mobifront/utils/utl.dart';
import 'package:mobifront/views/components/my_rounded_box.dart';
import 'package:mobifront/views/components/my_scaffold.dart';
import 'package:mobifront/views/home/home_controller.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  HomeController? controller;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      controller = ModalRoute.of(context)!.settings.arguments as HomeController;

      setState(() {});
    });
  }

  // célula de cabeçalho da tabela.
  getHeader(String caption, String field) {
    return InkWell(
        onTap: () {
          Future.delayed(Duration.zero, () {
            if (mounted) {
              setState(() {
                if (sortColumn == field) {
                  sortDirection = sortDirection == "asc" ? "desc" : "asc";
                } else {
                  sortColumn = field;
                  sortDirection = "asc";
                }
              });
            }
          });
        },
        child: MyRoundedBox(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(caption,
                  style: Theme.of(context)
                      .textTheme
                      .button!
                      .apply(fontWeightDelta: sortColumn == field ? 2 : 0)),
              if (sortColumn == field)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    sortDirection == "asc"
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 16,
                  ),
                )
            ],
          ),
        ));
  }

  String sortColumn = "date";
  String sortDirection = "asc";

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      controller!.sortReport(sortColumn, sortDirection);
    }

    return MyScaffold(
        title: "Média Movel",
        child: Semantics(
            label: "Detalhes da média móvel",
            child: controller == null
                ? Container()
                : Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 32),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                              child: getHeader("Data", "date"),
                            ),
                            SizedBox(
                              width: 20.w,
                              child: getHeader("Casos", "cases"),
                            ),
                            SizedBox(
                              width: 20.w,
                              child: getHeader("Média", "media"),
                            ),
                            SizedBox(
                              width: 30.w,
                              child: getHeader("Variação", "variation"),
                            ),
                          ],
                        ),
                        ...controller!.report.map((e) {
                          double variation = e.valuey - e.valuez;
                          double percent = variation * 100 / e.valuey;
                          bool negative = false;
                          if (percent < 0) {
                            negative = true;
                            percent = 0 - percent;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20.w,
                                  child: Text(Utl.brDate(Utl.asDate(e.data))),
                                ),
                                SizedBox(
                                    width: 20.w,
                                    child: Text(Utl.intNumber(e.valuex),
                                        textAlign: TextAlign.center)),
                                SizedBox(
                                  width: 20.w,
                                  child: Text(Utl.intNumber(e.valuey),
                                      textAlign: TextAlign.center),
                                ),
                                SizedBox(
                                  width: 30.w,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(Utl.intNumber(variation),
                                            textAlign: TextAlign.right),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child:
                                                Text(Utl.percent(percent, 1)),
                                          ),
                                          Icon(
                                            negative
                                                ? Icons.keyboard_arrow_down
                                                : Icons.keyboard_arrow_up,
                                            color: negative
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                      ],
                    ),
                  )));
  }
}
