import 'package:flutter/material.dart';
import 'package:happyscan/pages/pages.dart';
import 'package:happyscan/utils/utils.dart';

AuthService appAuth = AuthService();
bool result = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  result = await appAuth.checkAlreadyLogin();
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HappyScan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: navigatorKey,
      routes: <String, WidgetBuilder>{
        WelcomePage.routeName: (BuildContext _) => const WelcomePage(),
        HomePage.routeName: (BuildContext _) => const HomePage(),
      },
      onGenerateRoute: (settings) {
        if (result) {
          return MaterialPageRoute(
            builder: (context) {
              return const HomePage();
            },
          );
        } else {
          return MaterialPageRoute(
            builder: (context) {
              return const WelcomePage();
            },
          );
        }
      },
    );
  }
}
