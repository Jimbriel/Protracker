import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../models/cleaning_models.dart';

/// Muestra una firma (dibujada o registrada) con su etiqueta debajo.
class SignatureView extends StatelessWidget {
  final String label;
  final String? signature;

  const SignatureView({super.key, required this.label, this.signature});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 64,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _content(),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _content() {
    final s = signature;
    if (s == null) {
      return Text(
        'Pendiente',
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint),
      );
    }
    if (s.startsWith(kTextSignaturePrefix)) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          s.substring(kTextSignaturePrefix.length),
          maxLines: 2,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'serif',
            fontStyle: FontStyle.italic,
            fontSize: 15,
            color: AppColors.primaryDark,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Image.memory(base64Decode(s), fit: BoxFit.contain),
    );
  }
}
