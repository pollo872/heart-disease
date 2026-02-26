import 'package:flutter/material.dart';

class BaseButton extends StatelessWidget {
  String buttonTitle;
  Color titleColor;
  double borderRadius;

  Color borderColor;

  Color backgroundColor;
  final void Function()? onPressed;
  BaseButton({
    super.key,
    required this.buttonTitle,
    required this.titleColor,
    required this.borderRadius,
    required this.borderColor,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      width: 327,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          buttonTitle,
          style: TextStyle(
            color: titleColor,
            backgroundColor: Colors.transparent,
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(backgroundColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(color: borderColor),
            ),
          ),
        ),
      ),
    );
  }
}
