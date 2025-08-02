// ignore_for_file: unused_result
import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartVisibilityNotifier extends StateNotifier<bool> {
  CartVisibilityNotifier() : super(true);

  void setVisible(bool isVisible) {
    state = isVisible;
  }
}

final cartVisibilityProvider =
    StateNotifierProvider<CartVisibilityNotifier, bool>((ref) {
      return CartVisibilityNotifier();
    });

final cartItemCountProvider = StateProvider<int>((ref) => 0);

class CartContainer extends ConsumerWidget {
  const CartContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(sharedPreferencesCartProvider.notifier).loadCartItems();
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    final totalItems = cartItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    if (totalItems == 0) {
      return const SizedBox.shrink();
    }

    final isMobile = MediaQuery.of(context).size.width <= 800;
    final padding = isMobile ? 12.0 : 16.0;
    final fontSize = isMobile ? 16.0 : 18.0;
    final buttonFontSize = isMobile ? 14.0 : 16.0;
    final iconSize = isMobile ? 20.0 : 24.0;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 90,
      margin: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[50]!.withOpacity(0.8),
            const Color.fromARGB(255, 165, 134, 122),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 1),
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
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Cart',
                style: GoogleFonts.lora(
                  fontSize: fontSize,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$totalItems item${totalItems == 1 ? '' : 's'} selected',
                style: GoogleFonts.lora(
                  fontSize: fontSize - 4,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('selected_address');
              await prefs.remove('RazorpayorderId');
              context.push('/Cart');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: 8,
              ),
            ),
            child: Text(
              'Go to Cart',
              style: GoogleFonts.nunito(
                fontSize: buttonFontSize,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              CupertinoIcons.delete,
              color: AppColors.borderColor,
              size: iconSize,
            ),
            onPressed: () {
              final cartItems = ref.read(sharedPreferencesCartProvider);
              if (cartItems.isNotEmpty) {
                ref.read(sharedPreferencesCartProvider.notifier).clearCart();
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
