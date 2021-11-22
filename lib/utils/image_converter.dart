import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImageConverter {
  static Image imageFromBase64String(String base64String, double height) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.cover,
      height: height,
    );
  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }
}
