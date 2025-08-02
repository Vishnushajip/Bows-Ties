import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:bowsandties/Services/averageRatingProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CartActionButtons extends ConsumerWidget {
  final SharedPreferencesCartItem menuItem;

  const CartActionButtons({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    final cartNotifier = ref.read(sharedPreferencesCartProvider.notifier);
    final isInCart = cartItems.any((cartItem) => cartItem.id == menuItem.id);
    final cartItem = cartItems.firstWhere(
      (cartItem) => cartItem.id == menuItem.id,
      orElse: () => menuItem,
    );

    final ratingAsync = ref.watch(averageRatingProvider(menuItem.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ratingAsync.when(
          data: (rating) {
            if (rating == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.round() ? Icons.star : Icons.star_border,
                    color: Colors.orangeAccent,
                    size: 16,
                  );
                }),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Transform.translate(
                  offset: const Offset(0, -4),
                  child: const Text("₹", style: TextStyle(fontSize: 10)),
                ),
                const SizedBox(width: 2),
                Text(
                  "${menuItem.price.toStringAsFixed(0)} /-",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            Container(
              height: 42,
              width: MediaQuery.of(context).size.width * 0.35,
              decoration: BoxDecoration(
                color: AppColors.footercolor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink[100]!),
              ),
              child: isInCart
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: AppColors.primaryColor),
                          onPressed: () {
                            cartNotifier.decreaseItemQuantity(cartItem.id);
                          },
                        ),
                        Text(
                          cartItem.quantity.toString(),
                          style: GoogleFonts.poppins(color: AppColors.primaryColor),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: AppColors.primaryColor),
                          onPressed: () {
                            cartNotifier.increaseItemQuantity(cartItem.id);
                          },
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () {
                        final newCartItem = SharedPreferencesCartItem(
                          category: menuItem.category,
                          desc: menuItem.desc,
                          timestamp: DateTime.now(),
                          view: cartItem.view,
                          name: menuItem.name,
                          Color: menuItem.Color,
                          price: menuItem.price,
                          quantity: 1,
                          id: menuItem.id,
                          imageUrls: menuItem.imageUrls,
                        );
                        cartNotifier.addItemToCart(newCartItem);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.footercolor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        padding: EdgeInsets.zero,
                      ),
                      child: Center(
                        child: Text(
                          "ADD",
                          style: GoogleFonts.nunito(
                            color: AppColors.backgroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "(Inclusive of all taxes)",
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}
