import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReusableTextField extends StatelessWidget {
  final String label;
  final String hint;
  final int? max;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? initialValue;
  final TextEditingController? controller;
  final bool? text;

  const ReusableTextField({
    super.key,
    required this.label,
    required this.hint,
    this.onChanged,
    this.max,
    this.keyboardType,
    this.initialValue,
    this.controller,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return TextFormField(
      keyboardType: keyboardType,
      obscureText: ((text ?? false) && (max == null || max == 1)),
      controller: controller,
      maxLines: max ?? 1,
      style: GoogleFonts.poppins(fontSize: 13),
      cursorColor: Colors.black,
      initialValue: initialValue,
      decoration: InputDecoration(
        hintText: hint,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      onChanged: onChanged,
    );
  }
}
