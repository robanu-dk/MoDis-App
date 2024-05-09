import 'package:flutter/material.dart';

class TabButton extends StatelessWidget {
  const TabButton({
    super.key,
    required this.isActive,
    required this.onPressed,
    required this.label,
  });

  final bool isActive;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 50.0,
      child: isActive
          ? FilledButton(
              onPressed: onPressed,
              style: const ButtonStyle(
                padding: MaterialStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 10.0)),
                backgroundColor: MaterialStatePropertyAll(
                  Color.fromRGBO(248, 198, 48, 1),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: const ButtonStyle(
                side: MaterialStatePropertyAll(
                  BorderSide(
                    color: Color.fromARGB(255, 81, 81, 81),
                  ),
                ),
                padding: MaterialStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 10.0),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Color.fromARGB(255, 81, 81, 81),
                ),
              ),
            ),
    );
  }
}
