import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
    required this.fontSize,
    required this.imageSize,
  });

  final double imageSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            'images/logo.png',
            width: imageSize,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            'MoDis',
            style: TextStyle(
              fontFamily: 'Italianno',
              color: Colors.white,
              fontSize: fontSize,
            ),
          ),
        ),
      ],
    );
  }
}
