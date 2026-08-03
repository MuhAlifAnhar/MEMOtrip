import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class CustomGauge extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final double percentage; // 0.0 to 1.0

  const CustomGauge({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3949AB).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF3949AB), size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: DashedGaugePainter(percentage: percentage),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3949AB),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        unit,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white70,
                          fontSize: 10,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedGaugePainter extends CustomPainter {
  final double percentage;

  DashedGaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Background dashes (light grey-blue)
    final bgPaint = Paint()
      ..color = const Color(0xFF8C9EFF).withOpacity(0.4)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    // Foreground dashes (dark blue)
    final fgPaint = Paint()
      ..color = const Color(0xFF7986CB)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    const int totalDashes = 36; // Number of dashes around the circle
    const double gap = 0.05; // Gap between dashes in radians
    const double sweepAngle = (2 * pi) / totalDashes - gap;
    
    // Horseshoe gauge
    const double startOffset = pi * 0.75; 
    const double totalAngle = pi * 1.5;
    
    final int activeDashes = (percentage * totalDashes).round();

    for (int i = 0; i < totalDashes; i++) {
      final path = Path();
      double currentAngle = startOffset + (i * totalAngle / totalDashes);
      
      path.addArc(Rect.fromCircle(center: center, radius: radius), currentAngle, sweepAngle);
      
      if (i < activeDashes) {
        canvas.drawPath(path, fgPaint);
      } else {
        canvas.drawPath(path, bgPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
