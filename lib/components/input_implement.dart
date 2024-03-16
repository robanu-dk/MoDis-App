import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  const Input({
    super.key,
    required this.textController,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
  });
  final TextEditingController textController;
  final bool isPassword;
  final dynamic prefixIcon, suffixIcon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextField(
        controller: textController,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 10),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: const TextStyle(
            color: Color.fromRGBO(120, 120, 120, 1),
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        obscureText: isPassword,
      ),
    );
  }
}
