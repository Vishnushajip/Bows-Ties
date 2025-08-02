import 'package:bowsandties/Components/App_Colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.footercolor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          return Column(
            children: [
              isMobile
                  ? _buildMobileLayout(context)
                  : _buildDesktopLayout(context),
              const SizedBox(height: 30),
              Divider(
                color: AppColors.primaryColor.withOpacity(0.5),
                height: 1,
              ),
              const SizedBox(height: 20),
              _buildCopyright(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCompanyInfo(context, isMobile: true),
        const SizedBox(height: 30),
        _buildContactInfo(context, isMobile: true),
        const SizedBox(height: 30),
        _buildPolicyLinks(context, isMobile: true),
        const SizedBox(height: 30),
        _buildSocialMediaIcons(context, isMobile: true),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(flex: 2, child: _buildCompanyInfo(context, isMobile: false)),
          const VerticalDivider(
            color: AppColors.primaryColor,
            width: 1,
            thickness: 1,
          ),
          Expanded(child: _buildContactInfo(context, isMobile: false)),
          const VerticalDivider(
            color: AppColors.primaryColor,
            width: 1,
            thickness: 1,
          ),
          Expanded(child: _buildPolicyLinks(context, isMobile: false)),
          const VerticalDivider(
            color: AppColors.primaryColor,
            width: 1,
            thickness: 1,
          ),
          Expanded(child: _buildSocialMediaIcons(context, isMobile: false)),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo(BuildContext context, {required bool isMobile}) {
    return Padding(
      padding: isMobile
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.footercolor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.footercolor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bows & Ties',
              style: GoogleFonts.pacifico(
                color: AppColors.primaryColor,
                fontSize: 26,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Your one stop shop for premium ties, bow ties, and accessories. Quality and style guaranteed.',
              style: GoogleFonts.nunito(
                color: AppColors.primaryColor,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> launchUrlExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildContactInfo(BuildContext context, {required bool isMobile}) {
    return Padding(
      padding: isMobile
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.pink[50]!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.footercolor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Us',
              style: GoogleFonts.pacifico(
                color: AppColors.primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 15),
            _buildContactItem(
              Icons.email_outlined,
              'bowsandties2418@gmail.com',
              onTap: () =>
                  launchUrlExternal('mailto:bowsandties2418@gmail.com'),
            ),
            const SizedBox(height: 10),
            _buildContactItem(
              Icons.phone_outlined,
              '+91 90618 88369',
              onTap: () => launchUrlExternal('tel:+919061888369'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.nunito(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaIcons(
    BuildContext context, {
    required bool isMobile,
  }) {
    return Padding(
      padding: isMobile
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.footercolor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.footercolor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Follow Us',
              style: GoogleFonts.pacifico(
                color: AppColors.primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildSocialIcon(
                  FontAwesomeIcons.youtube,
                  const Color(0xFFFF0000),
                  () =>
                      launchUrlExternal("https://youtube.com/@bowsandties2418"),
                ),
                const SizedBox(width: 15),
                _buildSocialIcon(
                  FontAwesomeIcons.instagram,
                  const Color(0xFFE1306C),
                  () => launchUrlExternal(
                    "https://instagram.com/bowsandties2418",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.footercolor, width: 1),
        ),
        child: Center(child: Icon(icon, color: color, size: 20)),
      ),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Text(
      '© 2025 Bows & Ties. All Rights Reserved.',
      style: GoogleFonts.nunito(color: AppColors.primaryColor, fontSize: 12),
    );
  }

  Widget _buildPolicyLinks(BuildContext context, {required bool isMobile}) {
    final policyLinks = [
      {'title': 'Shipping Policy', 'route': '/shippingpolicy'},
      {'title': 'Terms & Conditions', 'route': '/termsandconditions'},
      {'title': 'Returns & Refunds', 'route': '/refund-policy'},
      {'title': 'Privacy Policy', 'route': '/privacypolicy'},
    ];

    return Padding(
      padding: isMobile
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Policies',
              style: GoogleFonts.pacifico(
                color: AppColors.primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 15),
            if (isMobile)
              ...policyLinks.map(
                (link) =>
                    _buildPolicyLink(link['title']!, link['route']!, context),
              )
            else
              Column(
                children: policyLinks
                    .map(
                      (link) => _buildPolicyLink(
                        link['title']!,
                        link['route']!,
                        context,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyLink(String title, String route, context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => GoRouter.of(context).push(route),
        hoverColor: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(
            title,
            style: GoogleFonts.nunito(
              color: AppColors.primaryColor,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
