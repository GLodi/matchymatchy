import 'package:flutter/material.dart';

Color colorOne = Colors.blue;
Color colorTwo = Colors.blue[300];

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    Paint paint = Paint();

    path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.60,
        size.width * 0.5, size.height * 0.80);
    path.quadraticBezierTo(
        size.width * 0.8, size.height, size.width, size.height * 0.75);
    path.lineTo(size.width, 0);
    path.close();

    paint.color = colorTwo;
    canvas.drawPath(path, paint);

    path = Path();
    path.lineTo(0, size.height * 0.65);
    path.quadraticBezierTo(
        size.width * 0.2, size.height, size.width * 0.6, size.height * 0.80);
    path.quadraticBezierTo(
        size.width * 0.8, size.height * 0.7, size.width, size.height * 0.80);
    path.lineTo(size.width, 0);
    path.close();

    paint.color = colorOne;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
