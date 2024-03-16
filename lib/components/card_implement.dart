import 'package:flutter/material.dart';

class CardImplement extends StatelessWidget {
  const CardImplement({
    super.key,
    required this.height,
    required this.opacity,
    required this.children,
    required this.componentAligment,
  });

  final double height;
  final double opacity;
  final List<Widget> children;
  final String componentAligment;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Opacity(
          opacity: opacity,
          child: Card(
            child: SizedBox(
              height: height,
              width: MediaQuery.of(context).size.width * 0.9,
            ),
          ),
        ),
        componentAligment == 'vertical'
            ? Column(
                children: children,
              )
            : Row(
                children: children,
              ),
      ],
    );
  }
}
