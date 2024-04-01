import 'package:flutter/material.dart';

class SearchModis extends StatelessWidget {
  const SearchModis({super.key, required this.onSubmitted, this.focusNode});
  final ValueChanged onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      textInputAction: TextInputAction.search,
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
