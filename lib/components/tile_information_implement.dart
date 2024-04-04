import 'package:flutter/material.dart';

class TileButton extends StatelessWidget {
  const TileButton({
    super.key,
    required this.onPressed,
    required this.height,
    required this.child,
    this.paddingTop = 8.0,
    this.paddingLeft = 10.0,
    this.paddingRight = 10.0,
  });

  final VoidCallback onPressed;
  final double height, paddingTop, paddingLeft, paddingRight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: paddingTop,
        left: paddingLeft,
        right: paddingRight,
      ),
      child: OutlinedButton(
        style: const ButtonStyle(
          padding: MaterialStatePropertyAll(EdgeInsets.zero),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Container(
          padding: const EdgeInsets.only(
            left: 12.0,
            top: 8.0,
            bottom: 8.0,
            right: 12.0,
          ),
          height: height,
          child: child,
        ),
      ),
    );
  }
}
