import 'dart:io' as Io;
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happyscan/blocs/blocs.dart';
import 'package:happyscan/main.dart';
import 'package:happyscan/models/document_details.dart';
import 'package:happyscan/pages/pages.dart';
import 'package:happyscan/styles/styles.dart';
import 'package:happyscan/utils/custom_dialogs.dart';
import 'package:happyscan/utils/utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdfPlugin;
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

final DocumentBloc editTodoBloc = DocumentBloc();

@immutable
class EditDocumentPageArguments {
  const EditDocumentPageArguments({
    required this.data,
  });

  final DocumentDetails data;
}

class EditDocumentPage extends StatefulWidget {
  static const String routeName = '/edit';
  const EditDocumentPage({
    Key? key,
  }) : super(key: key);

  @override
  _EditDocumentPageState createState() => _EditDocumentPageState();
}

class _EditDocumentPageState extends State<EditDocumentPage> {
  late EditDocumentPageArguments args;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args =
        ModalRoute.of(context)!.settings.arguments as EditDocumentPageArguments;
    if (args.data.image != null) _createFileFromString();
  }

  List<Uint8List> pdfPageList = <Uint8List>[];
  Future _createFileFromString() async {
    print('_createFileFromString');
    if (pdfPageList.isEmpty) {
      try {
        var data =
            await editTodoBloc.getTodoById(query: args.data.id.toString());
        setState(() {
          pdfPageList.clear();
        });

        if (data[0].docType == 1) {
          print('_createFileFromString 1');
          final document = await PdfDocument.openData(data[0].image!);
          for (int i = 1; i <= document.pagesCount; i++) {
            print('_createFileFromString i $i');
            final page = await document.getPage(i);
            final pdfImage =
                await page.render(width: page.width, height: page.height);
            if (pdfImage!.bytes.isNotEmpty) {
              pdfPageList.add(pdfImage.bytes);
            }
            await page.close();
            //await document.close();
          }
          setState(() {
            pdfPageList = pdfPageList;
          });
        } else {
          print('_createFileFromString else');
          pdfPageList.add(data[0].image!);
          setState(() {
            pdfPageList = pdfPageList;
          });
        }
      } catch (e) {
        return null;
      }
    }
  }

  int currentPos = 0;
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
      bottomSheet: bottomSheet(),
      backgroundColor: Colors.grey,
      body: pdfPageList.isNotEmpty
          ? Container(
              margin: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: CarouselSlider.builder(
                      options: CarouselOptions(
                        height: MediaQuery.of(context).size.height,
                        enlargeCenterPage: true,
                        initialPage: 0,
                        enableInfiniteScroll: false,
                        disableCenter: true,
                        autoPlay: false,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentPos = index;
                          });
                        },
                      ),
                      itemCount: pdfPageList.length,
                      itemBuilder: (BuildContext context, int itemIndex,
                              int pageViewIndex) =>
                          Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Image.memory(
                          pdfPageList[itemIndex],
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.height - 100,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: pdfPageList.map((url) {
                      int index = pdfPageList.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPos == index
                              ? const Color.fromRGBO(0, 0, 0, 0.9)
                              : const Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            )
          : const Center(child: Text('Please wait its loading...')),
      //floatingActionButton: fabBtns(),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 70,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          TextButton(
            onPressed: () {
              showBottomSheet();
              //selectImage();
            },
            child: Column(
              children: [
                const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Colors.black54,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Add Page',
                  style: smallTextStyle1,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          TextButton(
            onPressed: () async {
              /*final document =
                  await PdfDocument.openData(pdfPageList[currentPos]);
              final page = await document.getPage(1);
              final pdfImage =
                  await page.render(width: page.width, height: page.height);*/
              Io.Directory documentDirectory =
                  await getApplicationDocumentsDirectory();

              String documentPath = documentDirectory.path;

              Io.File file = Io.File("$documentPath/${args.data.docName}.png");

              file.writeAsBytesSync(pdfPageList[currentPos]);
              _cropImageNew(file);
            },
            child: Column(
              children: [
                const Icon(
                  Icons.crop,
                  color: Colors.black54,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Crop',
                  style: smallTextStyle1,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          TextButton(
            onPressed: () async {
              var data = await editTodoBloc.getTodoById(
                  query: args.data.id.toString());
              navigatorKey.currentState!.pushNamed(ViewDocumentPage.routeName,
                  arguments: ViewDocumentPageArguments(data: data[0]));
            },
            child: Column(
              children: [
                const Icon(
                  Icons.remove_red_eye_rounded,
                  color: Colors.black54,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'View',
                  style: smallTextStyle1,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          TextButton(
            onPressed: () {
              shareMyDoc();
            },
            child: Column(
              children: [
                const Icon(
                  Icons.share,
                  color: Colors.black54,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Share',
                  style: smallTextStyle1,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          TextButton(
            onPressed: () {
              CustomDialog.deleteAlert(args.data.id!);
            },
            child: Column(
              children: [
                const Icon(
                  Icons.delete,
                  color: Colors.black54,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Delete',
                  style: smallTextStyle1,
                ),
              ],
            ),
          ),
        ],
      ),
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
              ListTile(
                contentPadding: const EdgeInsets.only(left: 30, top: 10),
                leading: const Icon(
                  Icons.camera,
                  color: accentColor,
                ),
                horizontalTitleGap: 5,
                title: Text(
                  'Camera',
                  style: blackTexStyle,
                ),
                onTap: () {
                  Navigator.pop(context);
                  getImage();
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 30, bottom: 10),
                leading: const Icon(
                  Icons.photo_album,
                  color: accentColor,
                ),
                horizontalTitleGap: 5,
                title: Text(
                  'Gallery',
                  style: blackTexStyle,
                ),
                onTap: () {
                  selectImage();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Future<void> getImage() async {
    String? imagePath;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      imagePath = await EdgeDetection.detectEdge;
    } on PlatformException catch (e) {
      imagePath = e.toString();
    }
    if (!mounted) return;

    if (imagePath != null) {
      Io.File pickedFile = Io.File(imagePath);
      final pickedBytes = pickedFile.readAsBytesSync();
      pdfPageList.add(pickedBytes);
      for (var img in pdfPageList) {
        if (img.isNotEmpty) {
          final image = pw.MemoryImage(img);

          pdf.addPage(pw.Page(
              pageFormat: pdfPlugin.PdfPageFormat.a4,
              build: (pw.Context contex) {
                return pw.Image(
                  image,
                  fit: pw.BoxFit.cover,
                );
              }));
        }
      }
      setState(() {
        pdfPageList = pdfPageList;
      });

      Io.Directory documentDirectory = await getApplicationDocumentsDirectory();

      String documentPath = documentDirectory.path;

      Io.File file = Io.File("$documentPath/${args.data.docName}.pdf");

      file.writeAsBytesSync(await pdf.save());

      final String date = formatter.format(now);
      DocumentDetails data = DocumentDetails(
        image: file.readAsBytesSync(),
        createDate: date,
        docName: args.data.docName,
        docType: 1,
        isDone: true,
        id: args.data.id,
      );
      bloc.updateTodo(data);
    }
  }

  var pdf = pw.Document();
  void selectImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        Io.File pickedFile = Io.File(pickedImage.path);
        final pickedBytes = pickedFile.readAsBytesSync();
        pdfPageList.add(pickedBytes);
        for (var img in pdfPageList) {
          if (img.isNotEmpty) {
            final image = pw.MemoryImage(img);

            pdf.addPage(pw.Page(
                pageFormat: pdfPlugin.PdfPageFormat.a4,
                build: (pw.Context contex) {
                  return pw.Image(
                    image,
                    fit: pw.BoxFit.cover,
                  );
                }));
          }
        }
        setState(() {
          pdfPageList = pdfPageList;
        });

        Io.Directory documentDirectory =
            await getApplicationDocumentsDirectory();

        String documentPath = documentDirectory.path;

        Io.File file = Io.File("$documentPath/${args.data.docName}.pdf");

        file.writeAsBytesSync(await pdf.save());

        final String date = formatter.format(now);
        DocumentDetails data = DocumentDetails(
          image: file.readAsBytesSync(),
          createDate: date,
          docName: args.data.docName,
          docType: 1,
          isDone: true,
          id: args.data.id,
        );
        bloc.updateTodo(data);
      }
    } catch (e) {
      return;
    }
  }

  void shareMyDoc() async {
    try {
      //Share.share('check out my website https://example.com');
      var data = await editTodoBloc.getTodoById(query: args.data.id.toString());
      Uint8List bytes = data[0].image!;
      String dir = (await getApplicationDocumentsDirectory()).path;
      String fullPath =
          '$dir/${data[0].docName}.${data[0].docType == 1 ? 'pdf' : 'jpg'}';
      Io.File file = Io.File(fullPath);
      await file.writeAsBytes(bytes);
      Share.shareFiles(
        [fullPath],
      );
    } catch (e) {
      return null;
    }
  }

  final ImagePicker _picker = ImagePicker();

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  Future<void> _cropImageNew(Io.File imageFile) async {
    try {
      Io.File? croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        maxHeight: MediaQuery.of(context).size.height.toInt(),
        maxWidth: MediaQuery.of(context).size.width.toInt(),
        aspectRatioPresets: Io.Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: const AndroidUiSettings(
          toolbarTitle: 'Crop',
          backgroundColor: whiteColor,
          toolbarColor: lightGreyColor,
          toolbarWidgetColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        iosUiSettings: const IOSUiSettings(
          title: 'Crop',
        ),
      );
      if (croppedFile != null) {
        final pickedBytes = croppedFile.readAsBytesSync();
        pdfPageList[currentPos] = pickedBytes;
        for (var img in pdfPageList) {
          if (img.isNotEmpty) {
            final image = pw.MemoryImage(img);

            pdf.addPage(pw.Page(
                pageFormat: pdfPlugin.PdfPageFormat.a4,
                build: (pw.Context contex) {
                  return pw.Image(
                    image,
                    fit: pw.BoxFit.cover,
                  );
                }));
          }
        }
        setState(() {
          pdfPageList = pdfPageList;
        });

        Io.Directory documentDirectory =
            await getApplicationDocumentsDirectory();

        String documentPath = documentDirectory.path;

        Io.File file = Io.File("$documentPath/${args.data.docName}.pdf");

        file.writeAsBytesSync(await pdf.save());

        final String date = formatter.format(now);
        DocumentDetails data = DocumentDetails(
          image: file.readAsBytesSync(),
          createDate: date,
          docName: args.data.docName,
          docType: 1,
          isDone: true,
          id: args.data.id,
        );
        bloc.updateTodo(data);
        /*navigatorKey.currentState!.pushNamed(DetailsPage.routeName,
            arguments:
                DetailsPageArguments(image: croppedFile, data: args.data));*/
      }
    } catch (e) {
      return;
    }
  }
}
