import 'package:flutter/material.dart';

class TileButton extends StatelessWidget {
  const TileButton({
    super.key,
    required this.onPressed,
    required this.height,
    required this.child,
  });

  final VoidCallback onPressed;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 10.0, right: 10.0),
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
          padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
          height: height,
          child: child,
        ),
      ),
    );
  }
}
