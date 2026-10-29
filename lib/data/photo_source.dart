import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Toma o elige una foto y la devuelve en base64 (reducida para que quepa en
/// el almacenamiento local). Devuelve null si el usuario cancela.
Future<String?> pickPhoto(ImageSource source) async {
  final file = await ImagePicker().pickImage(
    source: source,
    maxWidth: 720,
    imageQuality: 60,
  );
  if (file == null) return null;
  return base64Encode(await file.readAsBytes());
}

/// Foto de muestra para presentar la demo en equipos sin cámara.
Future<String> samplePhoto(String caption) async {
  const w = 480.0, h = 360.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, w, h),
    Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(w, h),
        const [Color(0xFFBFD8DF), Color(0xFFE9F3F5)],
      ),
  );
  final icon = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(Icons.photo_camera_outlined.codePoint),
      style: TextStyle(
        fontFamily: Icons.photo_camera_outlined.fontFamily,
        fontSize: 96,
        color: const Color(0xFF0F3D4C),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  icon.paint(canvas, Offset((w - icon.width) / 2, 80));
  final text = TextPainter(
    text: TextSpan(
      text: 'Evidencia de muestra\n$caption',
      style: const TextStyle(fontSize: 22, color: Color(0xFF0F3D4C)),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: w - 40);
  text.paint(canvas, Offset((w - text.width) / 2, 220));
  final image = await recorder.endRecording().toImage(w.toInt(), h.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return base64Encode(data!.buffer.asUint8List());
}
