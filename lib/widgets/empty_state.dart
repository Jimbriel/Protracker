import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String label;

  const EmptyState({super.key, this.label = 'Sin datos para mostrar'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(120, 110),
            painter: _FolderPainter(),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final folderColor = AppColors.primary.withValues(alpha: 0.22);
    final folderDark = AppColors.secondary.withValues(alpha: 0.26);
    final paint = Paint()..style = PaintingStyle.fill;

    // folder body
    paint.color = folderColor;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, size.height * 0.42, size.width - 20, size.height * 0.52),
      const Radius.circular(10),
    );
    canvas.drawRRect(body, paint);

    // folder tab
    paint.color = folderDark;
    final tab = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, size.height * 0.34, size.width * 0.38, size.height * 0.14),
      const Radius.circular(6),
    );
    canvas.drawRRect(tab, paint);

    // paper falling
    final paperPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.82)
      ..style = PaintingStyle.fill;
    final paper = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.08,
        size.width * 0.22,
        size.height * 0.28,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(paper, paperPaint);

    // arc trajectory
    final arcPaint = Paint()
      ..color = folderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.56, size.height * 0.08);
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.1,
      size.width * 0.72,
      size.height * 0.22,
    );
    canvas.drawPath(path, arcPaint);

    // dot
    paint.color = folderColor;
    canvas.drawCircle(
      Offset(size.width * 0.74, size.height * 0.19),
      4,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
