import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

const _padSize = Size(280, 150);

/// Abre un cuadro para dibujar la firma. Devuelve el PNG en base64, o null si
/// se cancela.
Future<String?> showSignatureDialog(BuildContext context, String title) {
  return showDialog<String>(
    context: context,
    builder: (_) => _SignatureDialog(title: title),
  );
}

class _SignatureDialog extends StatefulWidget {
  final String title;
  const _SignatureDialog({required this.title});

  @override
  State<_SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<_SignatureDialog> {
  final _strokes = <List<Offset>>[];

  Future<String> _export() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    _paintStrokes(canvas, _strokes);
    final image = await recorder.endRecording().toImage(
          _padSize.width.toInt() * 2,
          _padSize.height.toInt() * 2,
        );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return base64Encode(data!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Dibuje su firma en el recuadro',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: _padSize.width,
            height: _padSize.height,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GestureDetector(
                onPanStart: (d) =>
                    setState(() => _strokes.add([d.localPosition])),
                onPanUpdate: (d) =>
                    setState(() => _strokes.last.add(d.localPosition)),
                child: CustomPaint(
                  size: _padSize,
                  painter: _PadPainter(_strokes),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _strokes.isEmpty ? null : () => setState(_strokes.clear),
          child: const Text('Limpiar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _strokes.isEmpty
              ? null
              : () async {
                  final navigator = Navigator.of(context);
                  navigator.pop(await _export());
                },
          child: const Text('Firmar'),
        ),
      ],
    );
  }
}

void _paintStrokes(Canvas canvas, List<List<Offset>> strokes) {
  final paint = Paint()
    ..color = AppColors.primaryDark
    ..strokeWidth = 2.5
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;
  // La exportación se hace al doble de tamaño para que se vea nítida.
  canvas.scale(2);
  for (final stroke in strokes) {
    if (stroke.length == 1) {
      canvas.drawCircle(stroke.first, 1.2, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
      continue;
    }
    final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
    for (final p in stroke.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }
}

class _PadPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _PadPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // _paintStrokes duplica la escala; aquí se compensa para pintar a 1x.
    canvas.scale(0.5);
    _paintStrokes(canvas, strokes);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PadPainter old) => true;
}
