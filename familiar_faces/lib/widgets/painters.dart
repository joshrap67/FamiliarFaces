import 'package:flutter/material.dart';

class FilmStrip extends CustomPainter {
  late Color color;

  FilmStrip(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var width = size.width * .12;
    for (var i = 0; i < 20; i++) {
      Path path = Path();
      path.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(i * width, 0.0, ((i) * width) + 25, size.height),
          Radius.circular(4),
        ),
      );
      canvas.drawPath(
        path,
        Paint()..color = this.color,
      );
    }
  }

  @override
  bool shouldRepaint(FilmStrip oldDelegate) {
    return false;
  }
}
