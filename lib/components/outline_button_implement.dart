import 'package:flutter/material.dart';

class OutlinedButtonModis extends StatelessWidget {
  const OutlinedButtonModis({
    super.key,
    required this.childrens,
    required this.onPressed,
    this.margin = const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 6.0),
    this.contentPadding,
    this.radius = 8.0,
  });

  final List<Widget> childrens;
  final VoidCallback onPressed;
  final EdgeInsets margin;
  final EdgeInsets? contentPadding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: OutlinedButton(
        style: contentPadding == null
            ? ButtonStyle(
                alignment: Alignment.centerLeft,
                side: const MaterialStatePropertyAll(
                    BorderSide(color: Colors.black)),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(radius)),
                  ),
                ),
              )
            : ButtonStyle(
                padding: MaterialStatePropertyAll(contentPadding),
                alignment: Alignment.centerLeft,
                side: const MaterialStatePropertyAll(
                    BorderSide(color: Colors.black)),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(radius)),
                  ),
                ),
              ),
        onPressed: onPressed,
        child: Row(
          children: childrens,
        ),
      ),
    );
  }
}
