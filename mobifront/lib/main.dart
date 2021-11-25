import 'package:flutter/material.dart';
import 'package:mobifront/views/details/details_page.dart';
import 'package:mobifront/views/home/home_page.dart';
import 'package:mobifront/views/topmost/top_most_page.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  } finally {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      Intl.defaultLocale = 'pt_BR';

      return MaterialApp(
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          title: 'Mobil.us Covid-19',
          supportedLocales: const [
            Locale('en', ''), // British English
            Locale('pt', ''), // Brazilian Portuguese
            // ...
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: const Locale('pt', ''),
          theme: ThemeData(
            primaryColor: const Color.fromARGB(255, 0, 18, 66),
          ),
          initialRoute: '/',
          routes: {
            // When navigating to the "/" route, build the FirstScreen widget.
            '/': (context) => const HomePage(),
            '/top_most': (context) => const TopMostPage(),
            '/details': (context) => const DetailsPage(),
          });
    });
  }
}
