import 'package:bowsandties/Components/App_Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Cancellations & Refunds',
          style: GoogleFonts.nunito(color: AppColors.primaryColor),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cancellation Policy',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Orders cannot be cancelled under any circumstances.\n• Once an order is placed, it is processed immediately.',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Refund Policy',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• We do not offer refunds.',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Return Policy',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• If you receive a damaged or missing product, it will be replaced immediately, provided you email an unedited and uncut unboxing video to bowsandties2418@gmail.com within 24 hours of receiving the parcel.\n• We are unable to accept any returns or exchanges if the unboxing video is shared after 24 hours.\n• Customers are responsible for the cost of return shipping.',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
