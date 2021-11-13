import 'package:flutter/material.dart';

class CustomBorderBtn extends StatelessWidget {
  final GestureTapCallback onPressed;
  final Color buttonBackgroundColor;
  final TextStyle buttonTestStyle;
  final EdgeInsets buttonMargin;
  final EdgeInsets buttonPadding;
  final String buttonName;
  final double buttonHeight;
  final double buttonWidth;
  final double buttonCornerRadius;
  final Color buttonBorderColor;
  final double textScaleFactor;

  const CustomBorderBtn({
    Key? key,
    required this.buttonBackgroundColor,
    required this.buttonTestStyle,
    required this.buttonName,
    required this.buttonMargin,
    required this.buttonPadding,
    required this.buttonHeight,
    required this.buttonWidth,
    required this.buttonCornerRadius,
    required this.buttonBorderColor,
    required this.onPressed,
    required this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: buttonMargin,
      child: SizedBox(
        width: buttonWidth,
        height: buttonHeight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: buttonBorderColor),
              borderRadius: BorderRadius.circular(buttonCornerRadius),
            ),
            primary: buttonBackgroundColor,
            padding: buttonPadding,
          ),
          child: Text(
            buttonName,
            textScaleFactor: textScaleFactor,
            style: buttonTestStyle,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
