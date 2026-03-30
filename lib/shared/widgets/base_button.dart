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
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(backgroundColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(color: borderColor),
            ),
          ),
        ),
        child: Text(
          buttonTitle,
          style: TextStyle(
            color: titleColor,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
