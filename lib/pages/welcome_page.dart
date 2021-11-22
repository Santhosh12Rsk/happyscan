import 'package:flutter/material.dart';
import 'package:happyscan/main.dart';
import 'package:happyscan/pages/pages.dart';
import 'package:happyscan/styles/styles.dart';
import 'package:happyscan/utils/utils.dart';
import 'package:happyscan/widgets/custom_text_btn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatelessWidget {
  static const String routeName = '/welcome';
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black54,
        bottomNavigationBar: getStartedBtn(),
        body: body(),
      ),
    );
  }

  Widget body() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          scanIcon(),
          happyScan(),
          appDescription(),
          progressBar(),
        ],
      ),
    );
  }

  Widget happyScan() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 25,
        right: 25,
        top: 25,
        bottom: 10,
      ),
      child: Text(
        happyScanText,
        style: titleTextStyleWhite,
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }

  Widget scanIcon() {
    return const Icon(
      Icons.camera,
      color: whiteColor,
      size: 90,
    );
  }

  Widget appDescription() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 25,
        right: 25,
        top: 10,
        bottom: 10,
      ),
      child: Text(
        scanDescText,
        style: lightWhiteTextStyle,
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }

  Widget progressBar() {
    return const Padding(
      padding: EdgeInsets.only(
        left: 70,
        right: 70,
        top: 100,
        bottom: 10,
      ),
      child: LinearProgressIndicator(
        // value: 50,
        backgroundColor: lightWhiteColor, value: 0,
        //color: lightWhiteColor,
        valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
      ),
    );
  }

  Widget getStartedBtn() {
    return SizedBox(
      height: 50,
      child: CustomTextBtn(
        onPressed: () async {
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setBool('isUserLoggedIn', true);
          navigatorKey.currentState!.pushNamed(HomePage.routeName);
        },
        txtName: getStartedText,
        btnTestStyle: whiteLargeStyle,
        txtAlign: Alignment.bottomCenter,
        margin: const EdgeInsets.only(bottom: 10),
      ),
    );
  }
}
