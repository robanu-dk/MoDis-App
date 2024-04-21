import 'package:flutter/material.dart';

class FlexRowInformation extends StatelessWidget {
  const FlexRowInformation({
    super.key,
    required this.label,
    required this.value,
    this.widthLabel,
    this.widthNameLabel,
    this.widthValue,
  });

  final String label, value;
  final double? widthLabel, widthNameLabel, widthValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: widthLabel ?? MediaQuery.of(context).size.width * 0.33,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: widthNameLabel ??
                      MediaQuery.of(context).size.width * 0.28,
                  child: Text(
                    maxLines: 2,
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                  child: const Text(
                    ': ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: widthValue ?? MediaQuery.of(context).size.width * 0.27,
            child: Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
