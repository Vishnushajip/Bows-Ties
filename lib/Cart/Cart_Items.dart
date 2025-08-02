// ignore_for_file: unused_result

import 'package:bowsandties/Cart/Categories.dart';
import 'package:bowsandties/Cart/Provider/cartProvider.dart';
import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:bowsandties/Services/Guest_Alert.dart';
import 'package:bowsandties/Services/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final checkoutLoadingProvider = StateProvider<bool>((ref) => false);

class ShowCart extends ConsumerWidget {
  const ShowCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(sharedPreferencesCartProvider);

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final totalPrice = cartItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'Cart',
            style: GoogleFonts.nunito(color: AppColors.primaryColor),
          ),
        ),
        elevation: 0.5,
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.network(
                      "https://static.vecteezy.com/system/resources/previews/016/462/240/non_2x/empty-shopping-cart-illustration-concept-on-white-background-vector.jpg",
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CategoryContainer(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                _buildCheckoutSection(
                  screenWidth,
                  screenHeight,
                  totalPrice,
                  cartItems,
                  context,
                  ref,
                ),
              ],
            ),
    );
  }

  Widget _buildCheckoutSection(
    double screenWidth,
    double screenHeight,
    double totalPrice,
    List<SharedPreferencesCartItem> cartItems,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _buildTotal(cartItems, screenWidth, screenHeight),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: double.infinity,
                child: Consumer(
                  builder: (context, ref, child) {
                    final isLoading = ref.watch(checkoutLoadingProvider);

                    return isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                                strokeWidth: 4.0,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.remove('deliveryInstructions');
                                    final email =
                                        prefs.getString('email') ?? '';

                                    if (email.isEmpty) {
                                      LoginBottomSheet.checkAndShow(context);
                                      return;
                                    }
                                    final selectedAddress = prefs.getStringList(
                                      'selected_address',
                                    );
                                    if (selectedAddress == null ||
                                        selectedAddress.length < 6) {
                                      context.push('/Address');
                                      return;
                                    }

                                    ref
                                            .read(
                                              checkoutLoadingProvider.notifier,
                                            )
                                            .state =
                                        true;

                                    try {
                                      final prefs =
                                          await SharedPreferences.getInstance();

                                      for (String key
                                          in prefs.getKeys().toList()) {
                                        if (key.startsWith('item_')) {
                                          await prefs.remove(key);
                                        }
                                      }
                                      for (
                                        int i = 0;
                                        i < cartItems.length;
                                        i++
                                      ) {
                                        final SharedPreferencesCartItem item =
                                            cartItems[i];
                                        await prefs.setString(
                                          'item_name_$i',
                                          item.name,
                                        );

                                        await prefs.setInt(
                                          'item_quantity_$i',
                                          item.quantity,
                                        );
                                        await prefs.setString(
                                          'item_imageUrl_$i',
                                          item.imageUrls[0],
                                        );
                                        await prefs.setDouble(
                                          'item_price_$i',
                                          item.price,
                                        );
                                      }
                                      context.pushReplacement("/OrderSummary");
                                      ref.refresh(cartProvider);
                                    } finally {
                                      ref
                                              .read(
                                                checkoutLoadingProvider
                                                    .notifier,
                                              )
                                              .state =
                                          false;
                                    }
                                    ref
                                        .read(orderProvider.notifier)
                                        .createOrder(totalPrice);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: FutureBuilder<String?>(
                              future: SharedPreferences.getInstance().then((
                                prefs,
                              ) {
                                final list = prefs.getStringList(
                                  'selected_address',
                                );
                                return (list != null && list.isNotEmpty)
                                    ? list[0]
                                    : null;
                              }),
                              builder: (context, snapshot) {
                                final savedAddressId = snapshot.data;
                                final buttonText =
                                    (savedAddressId == null ||
                                        savedAddressId.isEmpty)
                                    ? 'Select Address'
                                    : 'Continue';

                                return Text(
                                  buttonText,
                                  style: GoogleFonts.nunito(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.backgroundColor,
                                  ),
                                );
                              },
                            ),
                          );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotal(
    List<SharedPreferencesCartItem> cartItems,
    double screenWidth,
    double screenHeight,
  ) {
    final total = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Total Bill',
              style: GoogleFonts.nunito(fontSize: 20.0, color: Colors.black),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.description_outlined,
              size: 24.0,
              color: Color(0xFF273847),
            ),
          ],
        ),
        Text(
          '₹${total.toStringAsFixed(0)}/-',
          style: GoogleFonts.nunito(fontSize: 20.0, color: Colors.black),
        ),
      ],
    );
  }
}
