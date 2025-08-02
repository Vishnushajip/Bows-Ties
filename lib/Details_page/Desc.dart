import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:bowsandties/Services/share/Share_whatsapp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Description extends ConsumerWidget {
  final SharedPreferencesCartItem menuItem;

  const Description({required this.menuItem, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width <= 800;
    final padding = isMobile ? 5.0 : 24.0;
    final headingFontSize = isMobile ? 20.0 : 24.0;
    final bodyFontSize = isMobile ? 14.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.backgroundColor, width: 1),
      ),
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Product Details',
                style: GoogleFonts.nunito(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w400,
                  fontSize: headingFontSize,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              FloatingActionButton(
                mini: true,
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () {
                  sharePropertyOnWhatsApp(
                    imageUrl: menuItem.imageUrls.isNotEmpty
                        ? menuItem.imageUrls[0]
                        : '',
                    name: menuItem.name,
                    price: menuItem.price.toString(),
                    Id: menuItem.id,
                  );
                },
                child: Icon(
                  FontAwesomeIcons.share,
                  size: isMobile ? 14 : 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            menuItem.desc,
            textAlign: TextAlign.justify,
            style: GoogleFonts.nunito(
              color: AppColors.primaryColor,
              fontSize: bodyFontSize,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
