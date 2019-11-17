import 'package:flutter/material.dart';

class MultiErrorWidget extends StatefulWidget {
  final String message;

  MultiErrorWidget({this.message});

  @override
  State<StatefulWidget> createState() {
    return _MultiErrorWidget();
  }
}

class _MultiErrorWidget extends State<MultiErrorWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: 1,
      child: Visibility(
        visible: true,
        child: Center(
          child: Text(
            widget.message,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
