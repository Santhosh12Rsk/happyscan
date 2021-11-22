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
          SettingCardItem(
            title: aboutHappyScanText,
            icon: Icons.info_rounded,
            onClicked: () {},
          ),
          SettingCardItem(
            title: helpText,
            icon: Icons.help_sharp,
            onClicked: () {},
          ),
          SettingCardItem(
            title: rateAppText,
            icon: Icons.star_half_outlined,
            onClicked: () => _requestReview(),
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
      Share.share('check out my website https://example.com',
          subject: 'Look what I made!');
    } catch (e) {}
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
