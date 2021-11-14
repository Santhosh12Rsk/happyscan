import 'package:flutter/material.dart';
import 'package:happyscan/main.dart';
import 'package:happyscan/pages/scanner_page.dart';
import 'package:happyscan/styles/colors.dart';
import 'package:happyscan/styles/styles.dart';
import 'package:happyscan/utils/utils.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home';
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: lightGreyColor,
      floatingActionButton: fabBtn(),
      body: body(),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      backgroundColor: accentColor,
      automaticallyImplyLeading: false,
      title: const Text(happyText),
      actions: [
        const IconButton(
          onPressed: null,
          iconSize: 27,
          icon: Icon(
            Icons.search,
            color: whiteColor,
          ),
        ),
        IconButton(
          onPressed: () => showBottomSheet(),
          iconSize: 27,
          icon: const Icon(
            Icons.more_vert,
            color: whiteColor,
          ),
        ),
      ],
    );
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        backgroundColor: Colors.white,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 15,
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo,
                  color: greyColor,
                ),
                title: Text(
                  viewRecentScansText,
                  style: blackTexStyle,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_album,
                  color: greyColor,
                ),
                title: Text(
                  viewALlScansText,
                  style: blackTexStyle,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: greyColor,
                ),
                title: Text(
                  pdfConverterText,
                  style: blackTexStyle,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.settings,
                  color: greyColor,
                ),
                title: Text(
                  settingText,
                  style: blackTexStyle,
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Widget fabBtn() {
    return Container(
      height: 45,
      width: 110,
      decoration: const BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.all(
            Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 0.6,
            )
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () =>
                navigatorKey.currentState!.pushNamed(ScannerPage.routeName),
            icon: const Icon(
              Icons.camera_alt,
              color: whiteColor,
            ),
          ),
          const VerticalDivider(
            color: whiteColor,
            thickness: 1,
            width: 10,
            indent: 10,
            endIndent: 10,
          ),
          IconButton(
            onPressed: () =>
                navigatorKey.currentState!.pushNamed(ScannerPage.routeName),
            icon: const Icon(
              Icons.photo,
              color: whiteColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    return Center(
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          scanImage(),
          noScansText(),
        ],
      ),
    );
  }

  Widget scanImage() {
    return const Image(
      image: AssetImage('assets/images/scan.png'),
      height: 200,
      width: 200,
      fit: BoxFit.cover,
    );
  }

  Widget noScansText() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: noScansFoundText,
          style: semiBoldStyle,
          children: <TextSpan>[
            TextSpan(
              text: startNewScanText,
              style: greyTexStyle,
            )
          ],
        ),
      ),
    );
  }
}
