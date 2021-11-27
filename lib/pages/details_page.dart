import 'dart:io';

import 'package:flutter/material.dart';
import 'package:happyscan/blocs/blocs.dart';
import 'package:happyscan/main.dart';
import 'package:happyscan/models/document_details.dart';
import 'package:happyscan/pages/home_page.dart';
import 'package:happyscan/styles/styles.dart';
import 'package:happyscan/utils/utils.dart';
import 'package:happyscan/widgets/custom_text_btn.dart';
import 'package:happyscan/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

DocumentBloc bloc = DocumentBloc();

@immutable
class DetailsPageArguments {
  const DetailsPageArguments({
    required this.image,
    required this.data,
  });

  final DocumentDetails? data;
  final File? image;
}

class DetailsPage extends StatefulWidget {
  static const String routeName = '/details';
  const DetailsPage({Key? key}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  var pdf = pw.Document();
  late DetailsPageArguments args;
  String pdfFile = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit',
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
      bottomNavigationBar: buttons(),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Image.file(
            args.image!,
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
        ),
      ),
    );
  }

  Widget buttons() {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: CustomTextBtn(
              onPressed: () => navigatorKey.currentState!.pop(),
              txtName: 'Edit Again',
              btnTestStyle: blackTexStyle,
              txtAlign: Alignment.center,
              margin: const EdgeInsets.only(bottom: 10),
            ),
          ),
          Flexible(
            child: CustomBtn(
              primaryColor: accentColor,
              surfaceColor: accentColor,
              buttonTestStyle: whiteBtnStyle,
              buttonName: 'Update',
              buttonMargin: const EdgeInsets.only(right: 20, bottom: 10),
              buttonPadding: EdgeInsets.zero,
              buttonHeight: 40,
              buttonWidth: 100,
              buttonCornerRadius: 30.0,
              buttonBorderColor: accentColor,
              onPressed: showBottomSheet,
              textScaleFactor: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final _formKey = GlobalKey<FormState>();
  void showBottomSheet() {
    bool isGallery = args.data!.docType == 0 ? true : false;
    bool isPdf = args.data!.docType == 1 ? true : false;
    TextEditingController titleController =
        TextEditingController(text: args.data!.docName ?? '');
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        backgroundColor: Colors.white,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              //height: heightOfModalBottomSheet,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Update Document',
                            style: blackTitleTexStyle,
                          ),
                          IconButton(
                              onPressed: () => navigatorKey.currentState!.pop(),
                              icon: const Icon(Icons.cancel)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        docTitleText,
                        style: blackTexStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 5, bottom: 10, right: 25, left: 20),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.green, width: 1.0),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            return null;
                          } else {
                            return 'Please enter document title';
                          }
                        },
                        maxLines: 1,
                        controller: titleController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.photo,
                        color: accentColor,
                      ),
                      title: Text(
                        imageText,
                        style: blackTexStyle,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      trailing: Checkbox(
                        value: isGallery,
                        activeColor: accentColor,
                        onChanged: (value) {
                          setState(() {
                            isGallery = true;
                            isPdf = false;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: accentColor,
                      ),
                      title: Text(
                        pdfText,
                        style: blackTexStyle,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      trailing: Checkbox(
                        value: isPdf,
                        activeColor: accentColor,
                        onChanged: (value) {
                          setState(() {
                            isPdf = true;
                            isGallery = false;
                          });
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomBtn(
                        primaryColor: accentColor,
                        surfaceColor: accentColor,
                        buttonTestStyle: whiteBtnStyle,
                        buttonName: saveText,
                        buttonMargin:
                            const EdgeInsets.only(right: 20, bottom: 10),
                        buttonPadding: EdgeInsets.zero,
                        buttonHeight: 37,
                        buttonWidth: 90,
                        buttonCornerRadius: 30.0,
                        buttonBorderColor: accentColor,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (isGallery == true || isPdf == true) {
                              FocusScope.of(context).requestFocus(FocusNode());
                              final String date = formatter.format(now);

                              String? imgString;
                              if (isPdf == true) {
                                try {
                                  var pdf = pw.Document();
                                  final image1 = pw.MemoryImage(
                                    args.image!.readAsBytesSync(),
                                  );

                                  pdf.addPage(pw.Page(
                                      pageFormat: PdfPageFormat.a4,
                                      build: (pw.Context context) {
                                        return pw.Center(
                                          child: pw.Image(image1),
                                        ); // Center
                                      }));

                                  Directory documentDirectory =
                                      await getApplicationDocumentsDirectory();

                                  String documentPath = documentDirectory.path;

                                  File file = File(
                                      "$documentPath/${titleController.text}.pdf");

                                  file.writeAsBytesSync(await pdf.save());

                                  imgString = ImageConverter.base64String(
                                      file.readAsBytesSync());
                                } catch (e) {
                                  //print('pdf error $e');
                                }
                              } else {
                                imgString = ImageConverter.base64String(
                                    args.image!.readAsBytesSync());
                              }
                              DocumentDetails data = DocumentDetails(
                                image: args.image!.readAsBytesSync(),
                                createDate: date,
                                docName: titleController.text,
                                docType: isPdf == true ? 1 : 0,
                                isDone: true,
                                id: args.data!.id,
                              );
                              bloc.updateTodo(data);
                              navigatorKey.currentState!
                                  .pushNamedAndRemoveUntil(
                                      HomePage.routeName, (route) => true);
                            } else {
                              CustomDialog.customAlert('Document Format Error',
                                  'Please choose gallery of pdf to save');
                            }
                          }
                        },
                        textScaleFactor: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    args = ModalRoute.of(context)!.settings.arguments as DetailsPageArguments;
  }
}
