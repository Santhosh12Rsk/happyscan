import 'package:flutter/material.dart';

class CustomTextBtn extends StatelessWidget {
  final GestureTapCallback? onPressed;
  final String txtName;
  final TextStyle btnTestStyle;
  final Alignment txtAlign;
  final EdgeInsets margin;

  const CustomTextBtn({
    Key? key,
    required this.onPressed,
    required this.txtName,
    required this.btnTestStyle,
    required this.txtAlign,
    required this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = TextButton(
      child: Text(
        txtName,
        style: btnTestStyle,
      ),
      onPressed: onPressed,
    );
    final padding = Padding(
      padding: margin,
      child: text,
    );
    return Align(
      alignment: txtAlign,
      child: padding,
    );
  }
}
