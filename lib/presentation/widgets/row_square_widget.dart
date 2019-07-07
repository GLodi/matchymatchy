import 'package:flutter/material.dart';
import "dart:math";

const colors2 = {
  0: Colors.white,
  1: Colors.blue,
  2: Colors.orange,
  3: Colors.yellow,
  4: Colors.green,
  5: Colors.red,
};

class RowSquareWidget extends StatelessWidget {
  final double width;
  final _random = Random();

  RowSquareWidget({this.width});

  @override
  Widget build(BuildContext context) {
    var l = List<Widget>();
    for (int i = 0; i < 5; i++) l.add(square());
    return Row(children: l);
  }

  Widget square() {
    return Container(
      width: width,
      height: width,
      child: Container(
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: colors2[_random.nextInt(colors2.length)],
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
      ),
    );
  }
}
