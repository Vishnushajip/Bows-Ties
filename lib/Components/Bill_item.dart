import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BillItem extends StatelessWidget {
  final Color amountColor;
  final String title;
  final dynamic amount;
  final bool isRightAligned;
  final bool isBold;

  const BillItem({
    required this.amountColor,
    required this.title,
    required this.amount,
    this.isRightAligned = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isRightAligned
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.montserrat(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        if (amount is String)
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          )
        else if (amount is Widget)
          amount,
      ],
    );
  }
}