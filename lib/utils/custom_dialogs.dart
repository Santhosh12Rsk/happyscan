import 'package:flutter/material.dart';
import 'package:happyscan/blocs/blocs.dart';
import 'package:happyscan/main.dart';
import 'package:happyscan/pages/home_page.dart';

final DocumentBloc alertBloc = DocumentBloc();

class CustomDialog {
  static Future<void> customAlert(String title, String msg) async {
    var alert = AlertDialog(
      elevation: 6,
      title: Text(title),
      content: Text(msg),
      actions: <Widget>[
        TextButton(
            onPressed: () async {
              // final sharedPref = await SharedPreferences.getInstance();
              //sharedPref.clear();
              navigatorKey.currentState!.pop();
            },
            child: const Text(
              "Ok",
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

  static Future<void> deleteAlert(int id) async {
    var alert = AlertDialog(
      elevation: 6,
      title: const Text('Are you sure ?'),
      content: const Text(
        'Do you want to delete this document?',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            // final sharedPref = await SharedPreferences.getInstance();
            //sharedPref.clear();
            navigatorKey.currentState!.pop();
          },
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.blue),
          ),
        ),
        TextButton(
          onPressed: () async {
            // final sharedPref = await SharedPreferences.getInstance();
            //sharedPref.clear();
            alertBloc.deleteTodoById(id);
            navigatorKey.currentState!
                .pushNamedAndRemoveUntil(HomePage.routeName, (route) => true);
          },
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.blue),
          ),
        )
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
