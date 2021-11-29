import 'dart:io';

import 'package:flutter/material.dart';
import 'package:happyscan/main.dart';
import 'package:happyscan/styles/styles.dart';
import 'package:happyscan/utils/constants.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

enum Availability { loading, available, unavailable }

class SettingPage extends StatefulWidget {
  static const String routeName = '/settings';
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final InAppReview _inAppReview = InAppReview.instance;

  String _appStoreId = '1596039168';
  String _microsoftStoreId = 'com.apptomate.happyscan';
  Availability _availability = Availability.loading;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      try {
        final isAvailable = await _inAppReview.isAvailable();

        setState(() {
          // This plugin cannot be tested on Android by installing your app
          // locally. See https://github.com/britannio/in_app_review#testing for
          // more information.
          _availability = isAvailable && !Platform.isAndroid
              ? Availability.available
              : Availability.unavailable;
        });
      } catch (e) {
        setState(() => _availability = Availability.unavailable);
      }
    });
  }

  void _setAppStoreId(String id) => _appStoreId = id;

  void _setMicrosoftStoreId(String id) => _microsoftStoreId = id;

  Future<void> _requestReview() => _inAppReview.requestReview();

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
        appStoreId: _appStoreId,
        microsoftStoreId: _microsoftStoreId,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          settingText,
          style: appBarTitleBlack,
        ),
        titleSpacing: 0,
        backgroundColor: lightGreyColor,
        leading: IconButton(
            onPressed: () => navigatorKey.currentState!.pop(),
            icon: const Icon(
              Icons.clear,
              color: blackColor,
            )),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          SettingCardItem(
            title: aboutHappyScanText,
            icon: Icons.info_rounded,
            onClicked: () {
              aboutHappyScanDialog();
            },
          ),
          SettingCardItem(
            title: helpText,
            icon: Icons.help_sharp,
            onClicked: () {
              helpDialog();
            },
          ),
          SettingCardItem(
            title: rateAppText,
            icon: Icons.star_half_outlined,
            onClicked: () {
              _requestReview();
            },
          ),
          SettingCardItem(
            title: shareThisAppText,
            icon: Icons.share_sharp,
            onClicked: () => shareMyApp(),
          ),
        ],
      ),
    );
  }

  void shareMyApp() async {
    try {
      if (Platform.isIOS) {
        //https://apps.apple.com/in/app/happyscan/id1596039168
        Share.share(
          'https://apps.apple.com/in/app/happyscan/id1596039168',
        );
      } else {
        Share.share('check out my website https://example.com',
            subject: 'Look what I made!');
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> aboutHappyScanDialog() async {
    var alert = AlertDialog(
      elevation: 6,
      title: const Text(aboutHappyScanText),
      contentPadding:
          const EdgeInsets.only(left: 22, right: 22, top: 20, bottom: 5),
      content: const Text(
          'Happyscan is a simple and easy use application to scan the documents and photos. It enables the users to convert the scanned images to PDF and JPEG which can be saved and shared across applications. This application originally designed and developed by Apptomate.\nHappy Scanning :)'),
      actions: <Widget>[
        TextButton(
            onPressed: () async {
              // final sharedPref = await SharedPreferences.getInstance();
              //sharedPref.clear();
              navigatorKey.currentState!.pop();
            },
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.blue),
            ))
      ],
    );
    showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentContext!,
        builder: (_) {
          return alert;
        }).then((val) {
      return true;
    });
  }

  Future<void> helpDialog() async {
    var alert = AlertDialog(
      elevation: 6,
      title: const Text(helpText),
      contentPadding:
          const EdgeInsets.only(left: 22, right: 22, top: 20, bottom: 5),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Please contact the below email for any queries or concerns.'),
          SizedBox(
            height: 3,
          ),
          Text(
            'hello@apptomate.co',
            style: TextStyle(
              fontSize: 15,
              color: accentColor,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () async {
              // final sharedPref = await SharedPreferences.getInstance();
              //sharedPref.clear();
              navigatorKey.currentState!.pop();
            },
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.blue),
            ))
      ],
    );
    showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentContext!,
        builder: (_) {
          return alert;
        }).then((val) {
      return true;
    });
  }
}

class SettingCardItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function? onClicked;
  const SettingCardItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: Icon(
            icon,
            color: Colors.grey,
          ),
          title: Text(
            title,
            style: blackTexStyle,
          ),
          onTap: () => onClicked!(),
        ),
        const Divider(
          color: greyColor,
          thickness: 0.5,
        ),
      ],
    );
  }
}
