import 'package:flutter/material.dart';

class UnderlineWidget extends StatefulWidget {
  final String title;
  final Function onTap;
  final TextEditingController controller;

  const UnderlineWidget({
    Key key,
    this.title,
    this.onTap,
    this.controller,
  }) : super(key: key);

  @override
  _UnderlineWidgetState createState() => _UnderlineWidgetState();
}

class _UnderlineWidgetState extends State<UnderlineWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextFormField(
          onTap: () => widget?.onTap?.call(),
          controller: widget.controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: widget.title,
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(top: 14.0),
          child: Icon(
            Icons.arrow_forward_ios,
            color: Colors.deepOrangeAccent,
          ),
        ),
      ],
    );
  }
}
