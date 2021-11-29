import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:happyscan/blocs/blocs.dart';
import 'package:happyscan/main.dart';
import 'package:happyscan/models/document_details.dart';
import 'package:happyscan/pages/pages.dart';
import 'package:happyscan/styles/styles.dart';
import 'package:happyscan/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

//Initialize our BLoC
final DocumentBloc todoBloc = DocumentBloc();

class HomePage extends StatefulWidget {
  static const String routeName = '/home';
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    todoBloc.getTodos();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            contentPadding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 20),
            title: Text(
              'Are you sure ?',
              style: subHeaderTextStyleBlack,
            ),
            content: const Text(
              'Do you want to close the app.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'No',
                  style: accentBtnStyle,
                ),
              ),
              TextButton(
                onPressed: () {
                  exit(0);
                },
                child: Text(
                  'Yes',
                  style: accentBtnStyle,
                ),
              ),
            ],
          ),
        );
        return true;
      },
      child: Scaffold(
        appBar: isSearchEnabled ? appBarWithTextBox() : appBar(),
        backgroundColor: lightGreyColor,
        floatingActionButton: fabBtn(),
        body: getTodosWidget(),
      ),
    );
  }

  bool isSearchEnabled = false;

  PreferredSizeWidget appBar() {
    return AppBar(
      backgroundColor: lightGreyColor,
      automaticallyImplyLeading: false,
      title: Text(
        happyText,
        style: appBarTitleBlack,
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              isSearchEnabled = true;
            });
          },
          iconSize: 27,
          icon: const Icon(
            Icons.search,
            color: blackColor,
          ),
        ),
        IconButton(
          onPressed: () => showBottomSheet(),
          iconSize: 27,
          icon: const Icon(
            Icons.more_vert,
            color: blackColor,
          ),
        ),
      ],
    );
  }

  final TextEditingController _searchController = TextEditingController();
  PreferredSizeWidget appBarWithTextBox() {
    return AppBar(
      backgroundColor: lightGreyColor,
      automaticallyImplyLeading: false,
      title: TextFormField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search with document name',
        ),
        onChanged: (value) {
          if (value.isNotEmpty) todoBloc.getSearchTodos(query: value);
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            todoBloc.getTodos();
            setState(() {
              isSearchEnabled = false;
            });
            _searchController.clear();
          },
          iconSize: 27,
          icon: const Icon(
            Icons.clear,
            color: blackColor,
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
                  final DateTime now = DateTime.now();
                  final DateFormat formatter = DateFormat('dd/MM/yyyy');
                  String query = formatter.format(now);
                  todoBloc.getTodos(query: query);
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
                  todoBloc.getTodos();
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
                  navigatorKey.currentState!.pushNamed(SettingPage.routeName);
                },
              ),
            ],
          );
        });
  }

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  Widget fabBtn() {
    return FloatingActionButton(
      onPressed: () async {
        var status = await Permission.camera.status;
        if (status.isDenied) {
          // We didn't ask for permission yet or the permission has been denied before but not permanently.
          // You can request multiple permissions at once.
          Map<Permission, PermissionStatus> statuses = await [
            Permission.camera,
            Permission.photos,
          ].request();
        }
        navigatorKey.currentState!.pushNamed(ScannerPage.routeName);
      },
      backgroundColor: accentColor,
      child: Image.asset(
        "assets/images/ic_scan.png",
        height: 25,
        width: 25,
      ),
    );
  }

  List<DocumentDetails> docList = <DocumentDetails>[];
  Widget getTodosWidget() {
    /*The StreamBuilder widget,
  basically this widget will take stream of data (todos)
  and construct the UI (with state) based on the stream
  */
    return StreamBuilder(
      stream: todoBloc.todos,
      builder: (BuildContext context,
          AsyncSnapshot<List<DocumentDetails>> snapshot) {
        if (!snapshot.hasData) {
          return noDocFound();
        } else {
          docList = snapshot.data!;
          return showDocList();
        }
      },
    );
  }

  Widget showDocList() {
    return docList.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: docList.length,
            itemBuilder: (context, index) {
              return DocumentCardItem(
                docData: docList[index],
              );
            },
          )
        : noDocFound();
  }

  Widget noDocFound() {
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
      height: 300,
      //fit: BoxFit.fill,
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

class DocumentCardItem extends StatelessWidget {
  final DocumentDetails docData;
  const DocumentCardItem({
    Key? key,
    required this.docData,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
      ),
      color: whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: docData.image != null
                  ? docData.docType == 0
                      ? Stack(
                          children: [
                            Container(
                              color: Colors.black12,
                              height: 80,
                              width: double.infinity,
                              child: Image.memory(
                                docData.image!,
                                fit: BoxFit.cover,
                                height: 80,
                              ),
                            ),
                            Positioned(
                              top: 52,
                              left: 107,
                              child: Container(
                                color: Colors.black12,
                                child: const Icon(
                                  Icons.insert_photo_rounded,
                                  color: accentColor,
                                ),
                              ),
                            )
                          ],
                        )
                      : PdfPreview(
                          image64: docData.image!,
                          name: docData.docName,
                        )
                  : Stack(
                      children: [
                        Container(
                          color: Colors.black12,
                          height: 80,
                          width: double.infinity,
                          child: Image.asset(
                            'assets/images/background.png',
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 52,
                          left: 107,
                          child: Container(
                            color: Colors.black12,
                            child: const Icon(
                              Icons.insert_photo_rounded,
                              color: accentColor,
                            ),
                          ),
                        )
                      ],
                    ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                    ),
                    child: Text(
                      docData.docName ?? '',
                      style: blackTexStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                    ),
                    child: Text(
                      docData.createDate ?? '',
                      style: smallGreyTexStyle,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          shareMyDoc(docData);
                        },
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.share_sharp,
                          size: 22,
                          color: greyColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          navigatorKey.currentState!.pushNamed(
                              ViewDocumentPage.routeName,
                              arguments:
                                  ViewDocumentPageArguments(data: docData));
                        },
                        iconSize: 20,
                        icon: const Icon(
                          Icons.remove_red_eye_rounded,
                          color: greyColor,
                          size: 22,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          navigatorKey.currentState!
                              .pushNamed(EditDocumentPage.routeName,
                                  arguments:
                                      EditDocumentPageArguments(data: docData))
                              .then((value) {
                            todoBloc.getTodos();
                          });
                        },
                        iconSize: 20,
                        icon: const Icon(
                          Icons.edit,
                          size: 22,
                          color: greyColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () => CustomDialog.deleteAlert(docData.id!),
                        iconSize: 20,
                        icon: const Icon(
                          Icons.delete,
                          size: 22,
                          color: greyColor,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void shareMyDoc(DocumentDetails docData) async {
    try {
      Uint8List bytes = docData.image!;
      String dir = (await getApplicationDocumentsDirectory()).path;
      String fullPath =
          '$dir/${docData.docName}.${docData.docType == 1 ? 'pdf' : 'jpg'}';
      File file = File(fullPath);
      await file.writeAsBytes(bytes);
      Share.shareFiles(
        [fullPath],
      );
    } catch (e) {
      return null;
    }
  }
}

class PdfPreview extends StatefulWidget {
  final Uint8List image64;
  final String? name;
  const PdfPreview({
    Key? key,
    required this.image64,
    required this.name,
  }) : super(key: key);

  @override
  _PdfPreviewState createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
  PdfDocument? document;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadDocument();
  }

  PdfPageImage? pdfImage;
  loadDocument() async {
    try {
      Uint8List bytes = widget.image64;

      final document = await PdfDocument.openData(bytes);
      final page = await document.getPage(1);
      pdfImage = await page.render(width: page.width, height: page.height);
      setState(() {
        pdfImage = pdfImage;
      });
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return pdfImage != null
        ? Stack(
            children: [
              Container(
                color: Colors.black12,
                height: 80,
                width: double.infinity,
                child: Image.memory(
                  pdfImage!.bytes,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 52,
                left: 107,
                child: Container(
                  color: Colors.black12,
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: accentColor,
                  ),
                ),
              )
            ],
          )
        : Stack(
            children: [
              Container(
                color: Colors.black12,
                height: 80,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/background.png',
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 52,
                left: 107,
                child: Container(
                  color: Colors.black12,
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: accentColor,
                  ),
                ),
              )
            ],
          );
  }
}
