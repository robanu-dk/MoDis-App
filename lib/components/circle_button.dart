import 'package:flutter/material.dart';

class CircleButtonModis extends StatelessWidget {
  const CircleButtonModis({
    super.key,
    required this.icon,
    required this.label,
    required this.colors,
    required this.margin,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final List<Color> colors;
  final EdgeInsetsGeometry margin;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(100),
              ),
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
