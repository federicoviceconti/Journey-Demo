import 'package:flutter/material.dart';

class BorderButton extends StatelessWidget {
  final double width;
  final Widget child;
  final Color color;
  final Function() onTap;
  final bool enable;

  const BorderButton({
    Key key,
    this.child,
    this.color,
    this.onTap,
    this.width,
    this.enable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(enable) {
          onTap?.call();
        }
      },
      child: Wrap(
        children: [
          Container(
            width: width,
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 48.0,
            ),
            decoration: BoxDecoration(
              color: !enable ? Colors.grey : (color ?? Colors.deepOrange),
              borderRadius: BorderRadius.circular(32.0),
            ),
            child: child ?? Container(),
          ),
        ],
      ),
    );
  }
}
