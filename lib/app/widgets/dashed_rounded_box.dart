import 'package:flutter/material.dart';

class DashedRoundedBox extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onTap;
  final double radius;
  final Color dashColor;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;
  final double height;

  const DashedRoundedBox({
    Key? key,
    this.child,
    this.onTap,
    this.radius = 20,
    this.dashColor = const Color(0xFF6D3DF4),
    this.dashWidth = 8,
    this.dashGap = 6,
    this.strokeWidth = 4,
    this.height = 160,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _DashedRoundedRectPainter(
            color: dashColor,
            strokeWidth: strokeWidth,
            dashWidth: dashWidth,
            dashGap: dashGap,
            radius: radius,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final double radius;

  _DashedRoundedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        final extract = metric.extractPath(distance, next);
        canvas.drawPath(extract, paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
