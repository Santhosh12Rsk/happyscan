import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:happyscan/main.dart';
import 'package:happyscan/models/document_details.dart';
import 'package:happyscan/styles/styles.dart';
import 'package:happyscan/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

@immutable
class ViewDocumentPageArguments {
  const ViewDocumentPageArguments({
    required this.data,
  });

  final DocumentDetails data;
}

class ViewDocumentPage extends StatefulWidget {
  static const String routeName = '/view';
  const ViewDocumentPage({Key? key}) : super(key: key);

  @override
  _ViewDocumentPageState createState() => _ViewDocumentPageState();
}

class _ViewDocumentPageState extends State<ViewDocumentPage> {
  late ViewDocumentPageArguments args;
  PDFDocument? document;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args =
        ModalRoute.of(context)!.settings.arguments as ViewDocumentPageArguments;
    if (args.data.docType == 1) loadDocument();
  }

  loadDocument() async {
    try {
      Directory documentDirectory = await getApplicationDocumentsDirectory();

      String documentPath = documentDirectory.path;

      File file = File("$documentPath/${args.data.docName}.pdf");

      file.writeAsBytesSync(args.data.image!);
      document = await PDFDocument.fromFile(file);
      setState(() {
        document = document;
      });
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: lightGreyColor,
      body: args.data.image != null ? body() : const SizedBox(),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      backgroundColor: lightGreyColor,
      title: Text(
        happyText,
        style: appBarTitleBlack,
      ),
      leading: IconButton(
          onPressed: () => navigatorKey.currentState!.pop(),
          icon: const Icon(
            Icons.clear,
            color: blackColor,
          )),
    );
  }

  Widget body() {
    if (args.data.docType == 0) {
      return Container(
        margin: const EdgeInsets.all(30),
        child: Image.memory(
          args.data.image!,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.all(0),
        child: document != null
            ? PDFViewer(
                document: document!,
                zoomSteps: 1,
                lazyLoad: false,
                showPicker: false,
              )
            : const SizedBox(),
      );
    }
  }
}
