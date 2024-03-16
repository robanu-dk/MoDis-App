import 'package:flutter/material.dart';

class Dropdown extends StatelessWidget {
  const Dropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.prefixIcon,
    required this.items,
    required this.onChange,
  });

  final String hint;
  final ValueChanged onChange;
  final Icon prefixIcon;
  final dynamic value;
  final List<DropdownMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      child: DropdownButton(
        underline: const Text(''),
        isExpanded: true,
        iconSize: 28,
        hint: Row(
          children: [
            prefixIcon,
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(
                hint,
                style: const TextStyle(
                  color: Color.fromRGBO(120, 120, 120, 1),
                ),
              ),
            ),
          ],
        ),
        value: value,
        items: items,
        onChanged: onChange,
      ),
    );
  }
}
