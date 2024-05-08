import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  const Input({
    super.key,
    required this.textController,
    required this.label,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.border = InputBorder.none,
    this.keyboardType = TextInputType.emailAddress,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.width,
  });
  final TextEditingController textController;
  final bool isPassword;
  final dynamic prefixIcon, suffixIcon, focusNode;
  final String label;
  final InputBorder border;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int? maxLines;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      width: width ?? MediaQuery.of(context).size.width * 0.8,
      child: TextField(
        onTap: () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        },
        focusNode: focusNode,
        controller: textController,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 10),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: border,
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: const TextStyle(
            color: Color.fromRGBO(120, 120, 120, 1),
          ),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: isPassword,
      ),
    );
  }
}
