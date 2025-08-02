import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class CategoryContainer extends ConsumerWidget {
  final double screenWidth;
  final double screenHeight;

  const CategoryContainer({
    required this.screenWidth,
    required this.screenHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cartItems.isEmpty
            ? Center(
                child: Text(
                  'No items in Cart',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: cartItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return CartItemWidget(
                    item: item,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onIncrement: () => ref
                        .read(sharedPreferencesCartProvider.notifier)
                        .increaseItemQuantity(item.id),
                    onDecrement: () => ref
                        .read(sharedPreferencesCartProvider.notifier)
                        .decreaseItemQuantity(item.id),
                    onDelete: () => ref
                        .read(sharedPreferencesCartProvider.notifier)
                        .removeItemFromCart(item.id),
                  );
                },
              ),
      ],
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final SharedPreferencesCartItem item;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  const CartItemWidget({
    required this.item,
    required this.screenWidth,
    required this.screenHeight,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = screenWidth <= 800;
    final padding = isMobile ? screenWidth * 0.03 : screenWidth * 0.02;
    final fontSize = isMobile ? 14.0 : 16.0;
    final iconSize = isMobile ? 20.0 : 24.0;
    final imageSize = isMobile ? screenWidth * 0.25 : screenWidth * 0.15;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenHeight * 0.015,
        horizontal: padding,
      ),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink[50]!.withOpacity(0.8), AppColors.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.borderColor,
            blurRadius: 6,
            offset: Offset(0, 3),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrls.isNotEmpty
                        ? item.imageUrls[0]
                        : '',
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: AppColors.borderColor,
                      highlightColor: Colors.pink[50]!,
                      child: Container(
                        width: imageSize,
                        height: imageSize,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: imageSize,
                      height: imageSize,
                      color: Colors.pink[50]!.withOpacity(0.2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  style: GoogleFonts.lora(
                    color: AppColors.primaryColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  '₹${item.price.toStringAsFixed(0)} /-',
                  style: GoogleFonts.lora(
                    color: AppColors.primaryColor,
                    fontSize: fontSize - 2,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.accentColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      "Remove",
                      style: GoogleFonts.pacifico(
                        fontSize: fontSize - 2,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove,
                        color: AppColors.primaryColor,
                        size: iconSize,
                      ),
                      onPressed: onDecrement,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: GoogleFonts.lora(
                          fontSize: fontSize,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: AppColors.primaryColor,
                        size: iconSize,
                      ),
                      onPressed: onIncrement,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                '₹${(item.price * item.quantity).toStringAsFixed(0)} /-',
                style: GoogleFonts.lora(
                  color: AppColors.backgroundColor,
                  fontSize: fontSize - 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
