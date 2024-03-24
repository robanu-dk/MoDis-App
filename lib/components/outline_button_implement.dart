import 'package:flutter/material.dart';

class OutlinedButtonModis extends StatelessWidget {
  const OutlinedButtonModis(
      {super.key, required this.childrens, required this.onPressed});

  final List<Widget> childrens;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 6.0),
      child: OutlinedButton(
        style: const ButtonStyle(
          alignment: Alignment.centerLeft,
          side: MaterialStatePropertyAll(
              BorderSide(color: Color.fromARGB(255, 123, 123, 123))),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
