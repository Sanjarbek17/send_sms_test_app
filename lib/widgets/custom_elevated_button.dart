import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? minWidth;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;

  const CustomElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.minWidth,
    this.minHeight,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(minWidth ?? 40, minHeight ?? 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: padding,
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
