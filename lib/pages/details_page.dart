import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'dart:io' as io;

@immutable
class DetailsPageArguments {
  DetailsPageArguments({
    required this.image,
  });

  final image;
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
  List<File> _files = [];
  String pdfFile = '';
  var doc;
  var directory;
  List files = [];
  bool _isvisible = true;

  void _listofFiles() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    String documentPath = documentDirectory.path;
    setState(() {
      files = io.Directory('$documentPath/').listSync();
      print('files  $files'); //use your folder name insted of resume.
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listofFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Visibility(
              visible: _isvisible,
              child: Container(
                width: 200,
                height: 200,
                child: Image.file(
                  args.image,
                ),
              ),
            ),
            TextButton(
                onPressed: () async {
                  await createPdfFile();
                  savePdfFile();
                },
                child: Text('Convert')),
            ListView.builder(
                shrinkWrap: true,
                itemCount: files.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: Colors.white,
                    margin: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        OpenFile.open(files[index].path);
                      },
                      child: ListTile(
                        title: Text(files[index].toString()),
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    args = ModalRoute.of(context)!.settings.arguments as DetailsPageArguments;
  }

  savePdfFile() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    String documentPath = documentDirectory.path;

    String id = DateTime.now().toString();

    File file = File("$documentPath/$id.pdf");

    file.writeAsBytesSync(await pdf.save());

    print('File Path ${file.path}');

    setState(() {
      pdfFile = file.path;
      pdf = pw.Document();
      _isvisible = false;

      //OpenFile.open(pdfFile);
    });
  }

  createPdfFile() {
    final image = pw.MemoryImage(
      args.image.readAsBytesSync(),
    );

    pdf.addPage(pw.MultiPage(
        margin: pw.EdgeInsets.all(10),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('Create a Simple PDF',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 26)),
                  pw.Divider(),
                  pw.Center(
                    child: pw.Image(image),
                  )
                ]),
          ];
        }));
  }
}
