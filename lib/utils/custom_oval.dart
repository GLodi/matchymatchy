import 'package:flutter/material.dart';

class CustomOval extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    Rect rect = Rect.fromLTRB(
        -size.width / 32, -size.height, size.width * (33 / 32), size.height);
    return rect;
  }

  @override
  bool shouldReclip(CustomOval oldClipper) {
    return true;
  }
}
