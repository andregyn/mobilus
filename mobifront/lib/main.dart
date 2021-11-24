import 'package:flutter/material.dart';
import 'package:mobifront/views/home/home_page.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MaterialApp(
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          title: 'Mobil.us Covid-19',
          theme: ThemeData(
            primaryColor: const Color.fromARGB(255, 0, 18, 66),
          ),
          initialRoute: '/',
          routes: {
            // When navigating to the "/" route, build the FirstScreen widget.
            '/': (context) => const HomePage(),
          });
    });
  }
}
