import 'package:bowsandties/Components/App_Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ResponsiveCard extends StatelessWidget {
  const ResponsiveCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;
    final logoSize = isMobile ? 70.0 : 90.0;
    final iconSize = isMobile ? 22.0 : 26.0;
    final fontSize = isMobile ? 12.0 : 14.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.20,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Bows &",
                      style: GoogleFonts.pacifico(
                        fontSize: logoSize * 0.35,
                        color: AppColors.primaryColor,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      "Ties.in",
                      style: GoogleFonts.pacifico(
                        fontSize: logoSize * 0.30,
                        color: AppColors.primaryColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "www.bowsandties.in",
                      style: GoogleFonts.mochiyPopPOne(
                        fontSize: logoSize * 0.15,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCuteButton(
                          icon: Icons.shopping_bag_outlined,
                          label: "Cart",
                          onTap: () => context.push("/Cart"),
                          iconSize: iconSize,
                          fontSize: fontSize,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCuteButton(
                          icon: CupertinoIcons.person_fill,
                          label: "Profile",
                          onTap: () => Scaffold.of(context).openDrawer(),
                          iconSize: iconSize,
                          fontSize: fontSize,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildCuteButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  required double iconSize,
  required double fontSize,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      FloatingActionButton(
        mini: true,
        onPressed: onTap,
        backgroundColor: AppColors.footercolor,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.black, size: iconSize),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
        ),
      ),
    ],
  );
}
