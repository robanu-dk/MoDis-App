import 'package:flutter/material.dart';

class ModisAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ModisAppBar({
    super.key,
    required this.action,
    required this.title,
    this.header,
    this.paddingHeader = 1.5,
    this.noFreeSpace = false,
    this.colorFreeSpace = Colors.white,
  });

  final Widget title, action;
  final Widget? header;
  final double paddingHeader;
  final bool noFreeSpace;
  final Color colorFreeSpace;

  @override
  State<ModisAppBar> createState() => _ModisAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight * paddingHeader);
}

class _ModisAppBarState extends State<ModisAppBar> {
  @override
  Widget build(BuildContext context) {
    return widget.noFreeSpace
        ? Container(
            padding: const EdgeInsets.only(
                top: 25.0, bottom: 10.0, left: 15.0, right: 15.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color.fromRGBO(1, 92, 104, 1),
                  Color.fromRGBO(1, 135, 76, 1),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.title,
                widget.action,
              ],
            ),
          )
        : Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 25.0, bottom: 30.0, left: 15.0, right: 15.0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color.fromRGBO(1, 92, 104, 1),
                      Color.fromRGBO(1, 135, 76, 1),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.title,
                    widget.action,
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                margin: const EdgeInsets.only(top: 90.0),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(17)),
                  color: widget.colorFreeSpace,
                ),
                child: widget.header,
              )
            ],
          );
  }
}
