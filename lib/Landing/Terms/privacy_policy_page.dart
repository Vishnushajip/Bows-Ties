import 'package:bowsandties/Components/App_Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Privacy Policy',
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
              'Information We Collect',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Personal details (name, address, contact info)\n• Payment information (processed securely)\n• Order history and preferences',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'How We Use Your Data',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Process and fulfill your orders\n• Improve our products and services\n• Communicate order updates\n• Prevent fraud and ensure security',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Data Protection',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We implement security measures to protect your personal information. We do not sell or share your data with third parties for marketing purposes.',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Contact Us',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'For any privacy concerns, email us at bowsandties2418@gmail.com',
              style: GoogleFonts.nunito(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
