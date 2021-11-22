import 'dart:convert';
import 'dart:io' as Io;
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
    if (imageFile != null) {
      imageFile = null;
    }
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
    try {
      Uint8List bytes = base64.decode(args.data.image!);
      //String dir = (await getApplicationDocumentsDirectory()).path;
      //String fullPath = '$dir/${args.data.docName}.png';
      //Io.File file = Io.File(fullPath);
      if (args.data.docType == 1) {
        final document = await PdfDocument.openData(bytes);
        int count = document.pagesCount;
        print('edit document count $count');
        for (int i = 0; i <= count; i++) {
          final page = await document.getPage(i + 1);
          final pdfImage =
              await page.render(width: page.width, height: page.height);

          pdfPageList.add(pdfImage!.bytes);
          setState(() {
            pdfPageList = pdfPageList;
          });
          print('edit document length ${pdfPageList.length}');
        }
      } else {
        //await file.writeAsBytes(bytes);
      }
    } catch (e) {
      print('edit document error $e');
      return null;
    }
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
      bottomSheet: bottomSheet(),
      backgroundColor: Colors.grey,
      body: pdfPageList.isNotEmpty
          ? Container(
              margin: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 80),
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height,
                  enlargeCenterPage: true,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  disableCenter: true,
                  autoPlay: false,
                  autoPlayCurve: Curves.fastOutSlowIn,
                ),
                itemCount: pdfPageList.length,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) =>
                        Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Image.memory(
                    pdfPageList[itemIndex],
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
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
              selectImage();
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
            onPressed: () {
              _cropImageNew(imageFile!);
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
            onPressed: () {
              shareMyDoc(args.data);
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

  void shareMyDoc(DocumentDetails docData) async {
    try {
      //Share.share('check out my website https://example.com');

      Uint8List bytes = base64.decode(docData.image!);
      String dir = (await getApplicationDocumentsDirectory()).path;
      String fullPath =
          '$dir/${docData.docName}.${docData.docType == 1 ? 'pdf' : 'png'}';
      Io.File file = Io.File(fullPath);
      await file.writeAsBytes(bytes);
      Share.shareFiles([fullPath], text: 'Happy Scan Document');
    } catch (e) {}
  }

  final ImagePicker _picker = ImagePicker();

  var pdf = pw.Document();
  void selectImage() async {
    try {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        Io.File pickedFile = Io.File(pickedImage.path);
        Uint8List bytes = base64.decode(args.data.image!);

        final document = await PdfDocument.openData(bytes);
        int count = document.pagesCount;
        for (int i = 0; i <= count; i++) {
          final page = await document.getPage(i + 1);
          final pdfImage =
              await page.render(width: page.width, height: page.height);

          final image1 = pw.MemoryImage(
            pdfImage!.bytes,
          );

          pdf.addPage(pw.Page(
              pageFormat: pdfPlugin.PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Image(image1),
                ); // Center
              }));
        }

        final image1 = pw.MemoryImage(
          pickedFile.readAsBytesSync(),
        );

        pdf.addPage(pw.Page(
            pageFormat: pdfPlugin.PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image1),
              ); // Center
            }));

        Io.Directory documentDirectory =
            await getApplicationDocumentsDirectory();

        String documentPath = documentDirectory.path;

        Io.File file = Io.File("$documentPath/${args.data.docName}.pdf");

        file.writeAsBytesSync(await pdf.save());

        String imgString = ImageConverter.base64String(file.readAsBytesSync());
        final String date = formatter.format(now);
        DocumentDetails data = DocumentDetails(
          image: imgString,
          createDate: date,
          docName: args.data.docName,
          docType: args.data.docType,
          isDone: true,
          id: args.data.id,
        );
        bloc.updateTodo(data);
      }
    } catch (e) {
      print('select image error $e');
    }
  }

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  Widget fabBtns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          backgroundColor: accentColor,
          onPressed: () {
            _cropImageNew(imageFile!);
          },
          child: const Icon(Icons.crop),
        ),
        const SizedBox(
          width: 10,
        ),
        FloatingActionButton(
          backgroundColor: accentColor,
          onPressed: () {
            //_cropImageNew(imageFile!);
            showBottomDocListSheet();
          },
          child: const Icon(Icons.add),
        )
      ],
    );
  }

  void showBottomDocListSheet() {
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
            return Container(
              height: 150,
              child: Padding(
                padding: EdgeInsets.all(20),
                //height: heightOfModalBottomSheet,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Image.file(
                      imageFile!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.fill,
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  Io.File? imageFile;

  Future<Null> _cropImageNew(Io.File imageFile) async {
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
        print('_cropImageNew if');
        setState(() {
          imageFile = croppedFile;
        });
        navigatorKey.currentState!.pushNamed(DetailsPage.routeName,
            arguments:
                DetailsPageArguments(image: croppedFile, data: args.data));
      }
      print('_cropImageNew croppedFile $croppedFile');
    } catch (e) {
      print('_cropImageNew $e');
    }
  }
}
