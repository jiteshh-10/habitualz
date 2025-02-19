import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircleProgressPainter extends CustomPainter {
  final double progress;

  CircleProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);

    // Draw the circular progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );

    // Draw the tick mark if progress is complete
    if (progress >= 0.9) {
      final tickPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final tickPath = Path()
        ..moveTo(center.dx - radius / 2, center.dy)
        ..lineTo(center.dx, center.dy + radius / 2)
        ..lineTo(center.dx + radius / 4, center.dy - radius / 4);

      canvas.drawPath(tickPath, tickPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
