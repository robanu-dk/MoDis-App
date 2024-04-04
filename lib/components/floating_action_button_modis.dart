import 'package:flutter/material.dart';

class FloatingActionButtonModis extends StatelessWidget {
  const FloatingActionButtonModis({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: const ButtonStyle(
        fixedSize: MaterialStatePropertyAll(
          Size.fromRadius(kRadialReactionRadius * 1.5),
        ),
        backgroundColor: MaterialStatePropertyAll(
          Color.fromRGBO(1, 98, 104, 1.0),
        ),
      ),
      icon: const Icon(
        Icons.add,
        color: Colors.white,
        size: 45.0,
      ),
    );
  }
}
