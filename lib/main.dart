import 'package:flutter/material.dart';
import 'package:happyscan/pages/pages.dart';

//AuthService appAuth = AuthService();
//bool result = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //result = await appAuth.checkAlreadyLogin();
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Happyscan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: navigatorKey,
      routes: <String, WidgetBuilder>{
        HomePage.routeName: (BuildContext _) => const HomePage(),
        ScannerPage.routeName: (BuildContext _) => const ScannerPage(),
        DetailsPage.routeName: (BuildContext _) => const DetailsPage(),
        SettingPage.routeName: (BuildContext _) => const SettingPage(),
        EditDocumentPage.routeName: (BuildContext _) =>
            const EditDocumentPage(),
        ViewDocumentPage.routeName: (BuildContext _) =>
            const ViewDocumentPage(),
      },
      /* onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return const HomePage();
          },
        );
      },*/
      home: const HomePage(),
    );
  }
}
