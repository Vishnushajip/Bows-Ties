// ignore_for_file: unused_result

import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

final menuItemsProvider = FutureProvider<List<SharedPreferencesCartItem>>((
  ref,
) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('Products')
      .get();
  return querySnapshot.docs
      .map((doc) => SharedPreferencesCartItem.fromJson(doc.data()))
      .toList();
});

class Suggestions extends ConsumerWidget {
  final SharedPreferencesCartItem menuItem;

  const Suggestions({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItemsAsync = ref.watch(menuItemsProvider);

    return menuItemsAsync.when(
      data: (menuItems) => _buildContent(context, menuItems, ref),
      loading: () => const Center(child: SizedBox.shrink()),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<SharedPreferencesCartItem> menuItems,
    WidgetRef ref,
  ) {
    final baseNameFilter = menuItem.name.toLowerCase();
    final isMobile = MediaQuery.of(context).size.width <= 800;

    final filteredItems = menuItems.where((item) {
      final isNameMatched = item.name.toLowerCase() == baseNameFilter;

      return isNameMatched;
    }).toList();

    final padding = isMobile ? 5.0 : 24.0;
    final headingFontSize = isMobile ? 18.0 : 22.0;
    final bodyFontSize = isMobile ? 12.0 : 14.0;
    final containerWidth = isMobile ? 80.0 : 160.0;
    final containerHeight = isMobile ? 80.0 : 160.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filteredItems.isNotEmpty)
            Text(
              'Colors',
              style: GoogleFonts.pacifico(
                fontSize: headingFontSize,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryColor,
              ),
            ),
          if (filteredItems.isNotEmpty) const SizedBox(height: 12),
          if (filteredItems.isNotEmpty)
            SizedBox(
              height: containerHeight + 50,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: filteredItems
                      .map(
                        (item) => _buildItemCard(
                          context,
                          item,
                          containerWidth,
                          containerHeight,
                          bodyFontSize,
                          ref,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          if (filteredItems.isEmpty) const SizedBox.shrink(),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    SharedPreferencesCartItem item,
    double width,
    double height,
    double bodyFontSize,
    WidgetRef ref,
  ) {
    return GestureDetector(
      onTap: () {
        ref.refresh(menuItemsProvider);
        context.push('/ProductDetails', extra: item);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor, width: 1),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrls.isNotEmpty
                          ? item.imageUrls[0]
                          : '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.borderColor,
                        highlightColor: Colors.pink[50]!,
                        child: Container(
                          width: width,
                          height: height,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: width,
                        height: height,
                        color: Colors.pink[50]!.withOpacity(0.2),
                        child: Icon(
                          Icons.pets,
                          color: Colors.pink[400],
                          size: width * 0.4,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.favorite_border,
                      color: AppColors.primaryColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: width,
              child: Text(
                item.Color,
                style: GoogleFonts.lora(
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
