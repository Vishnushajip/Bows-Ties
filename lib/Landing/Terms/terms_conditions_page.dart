import 'package:bowsandties/Components/App_Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.nunito(color: AppColors.primaryColor),
        ),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Order Acceptance',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All orders are subject to product availability. We reserve the right to refuse any order.',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              '2. Pricing',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prices are subject to change without notice. All prices are in INR.',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              '3. Product Information',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We make every effort to display product colors accurately, but actual colors may vary slightly.',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              '4. Governing Law',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'These terms shall be governed by the laws of India. Any disputes shall be subject to the jurisdiction of courts in Kerala.',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
