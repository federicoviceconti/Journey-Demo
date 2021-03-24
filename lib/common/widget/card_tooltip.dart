import 'package:flutter/material.dart';
import 'package:journey_demo/common/text/bold_text.dart';
import 'package:journey_demo/common/text/regular_text.dart';

class CardTooltip extends StatelessWidget {
  final double width;
  final String title;
  final String subtitle;

  const CardTooltip({
    Key key,
    this.width,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BoldText(
                title,
                color: Colors.black,
              ),
              SizedBox(height: 4),
              RegularText(
                subtitle,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
