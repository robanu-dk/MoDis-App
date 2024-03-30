import 'package:flutter/material.dart';

class SearchModis extends StatelessWidget {
  const SearchModis({super.key, required this.onChanged, this.focusNode});
  final ValueChanged onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      focusNode: focusNode,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        contentPadding: EdgeInsets.only(left: 22.0),
        suffixIcon: Icon(Icons.search),
        label: Text('Ketik disini untuk pencarian'),
      ),
    );
  }
}
