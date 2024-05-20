import 'package:flutter/material.dart';

class SearchModis extends StatelessWidget {
  const SearchModis({
    super.key,
    required this.onSubmitted,
    this.focusNode,
    this.controller,
    this.label = const Text('Ketik disini untuk pencarian'),
  });
  final ValueChanged onSubmitted;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Text label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: onSubmitted,
      onTap: () {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      },
      focusNode: focusNode,
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        contentPadding: const EdgeInsets.only(left: 22.0),
        suffixIcon: const Icon(Icons.search),
        label: label,
      ),
    );
  }
}
