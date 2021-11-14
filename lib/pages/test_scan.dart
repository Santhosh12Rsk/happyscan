import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happyscan/main.dart';
import 'package:happyscan/pages/details_page.dart';
import 'package:happyscan/styles/colors.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';

class TestScanner extends StatefulWidget {
  static const String routeName = '/test';
  @override
  _TestScannerState createState() => new _TestScannerState();
}

class _TestScannerState extends State<TestScanner> {
  final cropKey = GlobalKey<CropState>();
  var _file;
  var _sample;
  var _lastCropped;

  @override
  void dispose() {
    super.dispose();
    _file.delete();
    _sample.delete();
    _lastCropped.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        child: _sample == null ? _buildOpeningImage() : _buildCroppingImage(),
      ),
    );
  }

  Widget _buildOpeningImage() {
    return Center(child: _buildOpenImage());
  }

  Widget _buildCroppingImage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(_sample, key: cropKey),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20.0),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(
                child: Text(
                  'Crop Image',
                  style: Theme.of(context)
                      .textTheme
                      .button!
                      .copyWith(color: Colors.white),
                ),
                onPressed: () => _cropImage(),
              ),
              _buildOpenImage(),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildOpenImage() {
    return Column(
      children: [
        TextButton(
          child: Text(
            'Open Gallery Image',
            style: Theme.of(context)
                .textTheme
                .button!
                .copyWith(color: Colors.white),
          ),
          onPressed: () => _openImage(),
        ),
        TextButton(
          child: Text(
            'Open Camera Image',
            style: Theme.of(context)
                .textTheme
                .button!
                .copyWith(color: Colors.white),
          ),
          onPressed: () => _openCameraImage(),
        ),
      ],
    );
  }

  Future<void> _openImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    final file = File(pickedFile!.path);
    final sample = await ImageCrop.sampleImage(
      file: file,
      preferredSize: context.size!.longestSide.ceil(),
    );

    /*  _sample.delete();
    _file.delete();*/

    setState(() {
      _sample = sample;
      _file = file;
    });
  }

  Future<void> _openCameraImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 100);
    final file = File(pickedFile!.path);
    final sample = await ImageCrop.sampleImage(
      file: file,
      preferredSize: context.size!.longestSide.ceil(),
    );

    /*  _sample.delete();
    _file.delete();*/

    setState(() {
      _sample = sample;
      _file = file;
    });
  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState!.scale;
    final area = cropKey.currentState!.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: _file,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    // sample.delete();

    // _lastCropped.delete();
    _lastCropped = file;
    if (_lastCropped != null) {
      navigatorKey.currentState!.pushNamed(DetailsPage.routeName,
          arguments: DetailsPageArguments(image: _lastCropped));
    }

    debugPrint('$file');
  }
}
