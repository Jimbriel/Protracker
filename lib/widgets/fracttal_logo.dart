import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

class FracttalLogo extends StatelessWidget {
  final double size;
  final bool compact;

  const FracttalLogo({super.key, this.size = 32, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _DotMatrixIcon(size: size),
        const SizedBox(width: 10),
        if (!compact)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'PRO ',
                  style: GoogleFonts.inter(
                    fontSize: size * 0.72,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                TextSpan(
                  text: 'tracker',
                  style: GoogleFonts.inter(
                    fontSize: size * 0.72,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DotMatrixIcon extends StatelessWidget {
  final double size;
  const _DotMatrixIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DotMatrixPainter(),
    );
  }
}

class _DotMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final dotRadius = size.width * 0.08;
    final rows = 4;
    final cols = 4;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (r == 0 && c == 0) continue;
        if (r == 0 && c == cols - 1) continue;
        if (r == rows - 1 && c == 0) continue;

        final opacity = 1.0 - (r + c) * 0.06;
        paint.color = AppColors.primary.withValues(alpha: opacity.clamp(0.3, 1.0));

        final x = (c / (cols - 1)) * size.width;
        final y = (r / (rows - 1)) * size.height;
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
