import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  const SearchBox({
    Key key,
    this.hintText,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.all(20.0),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
