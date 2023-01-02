import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  CirclePainter({this.strokeWidth = 10}) {
    _paint = Paint()
      ..color = Colors.red
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
  }

  double strokeWidth;

  late Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.width, size.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
