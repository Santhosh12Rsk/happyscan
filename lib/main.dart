import 'package:flutter/material.dart';
import 'package:happyscan/pages/details_page.dart';
import 'package:happyscan/pages/pages.dart';
import 'package:happyscan/pages/test_scan.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Happy Scan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: navigatorKey,
      routes: <String, WidgetBuilder>{
        WelcomePage.routeName: (BuildContext _) => const WelcomePage(),
        HomePage.routeName: (BuildContext _) => const HomePage(),
        TestScanner.routeName: (BuildContext _) => TestScanner(),
        DetailsPage.routeName: (BuildContext _) => DetailsPage(),
      },
      home: const WelcomePage(),
    );
  }
}
