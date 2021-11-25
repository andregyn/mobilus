import 'package:flutter/material.dart';
import 'package:mobifront/utils/utl.dart';
import 'package:mobifront/views/components/my_rounded_box.dart';
import 'package:mobifront/views/components/my_scaffold.dart';
import 'package:mobifront/views/home/home_controller.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class TopMostPage extends StatefulWidget {
  const TopMostPage({Key? key}) : super(key: key);

  @override
  _TopMostPageState createState() => _TopMostPageState();
}

class _TopMostPageState extends State<TopMostPage> {
  HomeController? controller;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      controller = ModalRoute.of(context)!.settings.arguments as HomeController;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        title: "Piores dias",
        child: Semantics(
            label: "Piores dias neste último mês",
            child: controller == null
                ? Container()
                : Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 32),
                    child: Column(
                      children: [
                        ...controller!.fireDocs!.docs.map((e) {
                          String date =
                              Utl.brDateTime(Utl.asDate(e["date"] ?? ""));
                          String city =
                              (e['city'] ?? "") + "/" + (e['state'] ?? "");

                          String urlMaps = Utl.getGoogleMapUrl(
                              Utl.asString(e['latitude']) +
                                  "," +
                                  Utl.asString(e["longitude"]));

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: SizedBox(
                              width: 90.w,
                              child: MyRoundedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("Número de casos:",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1!),
                                              Text(
                                                  Utl.intNumber(
                                                      Utl.asFloat(e['cases'])),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6!),
                                              Text(
                                                  Utl.brDate(Utl.asDate(
                                                      e["cases_at"])),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1!
                                                      .apply(
                                                          color:
                                                              Colors.black54))
                                            ],
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("Número de mortes:",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1!),
                                              Text(
                                                  Utl.intNumber(
                                                      Utl.asFloat(e['deaths'])),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6!),
                                              Text(
                                                  Utl.brDate(Utl.asDate(
                                                      e["deaths_at"])),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1!
                                                      .apply(
                                                          color:
                                                              Colors.black54))
                                            ],
                                          )
                                        ]),
                                    SizedBox(
                                      width: 90.w - 32,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 64,
                                            child: IconButton(
                                                onPressed: () async {
                                                  if (await canLaunch(
                                                      urlMaps)) {
                                                    await launch(urlMaps);
                                                  } else {
                                                    throw 'Could not open the map.';
                                                  }
                                                },
                                                icon: const Icon(Icons.place,
                                                    color: Colors.blue)),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Leitura realizada em $date",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1!
                                                      .apply(
                                                          color:
                                                              Colors.black54),
                                                ),
                                                Text(
                                                  city,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1!
                                                      .apply(
                                                          color:
                                                              Colors.black54),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                      ],
                    ),
                  )));
  }
}
