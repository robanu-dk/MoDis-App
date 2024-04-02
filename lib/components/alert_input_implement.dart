import 'package:flutter/material.dart';

class AlertInput extends StatelessWidget {
  const AlertInput({
    super.key,
    this.height,
    required this.header,
    required this.headerPadding,
    required this.contents,
    required this.contentAligment,
    required this.contentPadding,
    required this.actionAligment,
    required this.actions,
    required this.actionPadding,
  });

  final Widget header;
  final List<Widget> contents, actions;
  final String actionAligment, contentAligment;
  final double? height;
  final EdgeInsetsGeometry headerPadding, contentPadding, actionPadding;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      scrollable: true,
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: height,
        child: Column(
          children: [
            Padding(
              padding: headerPadding,
              child: header,
            ),
            Padding(
              padding: contentPadding,
              child: contentAligment == 'vertical'
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: contents,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: contents,
                    ),
            ),
            Padding(
              padding: actionPadding,
              child: actionAligment == 'vertical'
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: actions,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: actions,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
