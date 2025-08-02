import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color color;
  final VoidCallback? onPressed;
  final Color? dividerColor;
  final double? fontSize;
  final double? iconsize;
  final Color? iconColor;

  const NavItem({
    super.key,
    required this.title,
    this.icon,
    this.iconsize,
    this.fontSize,
    this.iconColor,
    required this.color,
    this.onPressed,
    this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width <= 800;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth < 1000 ? 16 : 16;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: isMobile ? const BoxDecoration() : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
