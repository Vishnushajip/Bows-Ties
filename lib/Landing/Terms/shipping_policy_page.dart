import 'package:bowsandties/Components/App_Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShippingPolicyPage extends StatelessWidget {
  const ShippingPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Shipping Policy',
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
              'Delivery Timeframe',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Standard delivery: 4-7 business days\n• Processing time: 1-2 business days',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Shipping Methods & Costs',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Kerala: DTDC courier service\n• Other Indian states: IndiaPost or Professional Courier\n• International: Available with extra shipping cost\n• Shipping charges vary by location',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Note:',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Delivery times may vary during festivals or peak seasons. We provide tracking details for all shipments.',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
