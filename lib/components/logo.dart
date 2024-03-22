import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
    required this.fontSize,
    required this.imageSize,
    required this.mainAxisAlignment,
  });

  final double imageSize, fontSize;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
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
