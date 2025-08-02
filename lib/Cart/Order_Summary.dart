// ignore_for_file: unused_result

import 'package:bowsandties/Cart/Deliveryinst.dart';
import 'package:bowsandties/Cart/Provider/cartProvider.dart';
import 'package:bowsandties/Cart/payment_Method.dart';
import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Components/Bill_item.dart';
import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class OrderSummary extends ConsumerWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final isPaymentLoading = ref.watch(paymentLoadingProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Order Summary',
          style: GoogleFonts.nunito(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: cartAsync.when(
        data: (cartItems) => cartItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: isMobile ? 60 : 80,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: GoogleFonts.nunito(
                        fontSize: isMobile ? 16 : 20,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
                      child: ExpansionPanelList(
                        expansionCallback: (panelIndex, isExpanded) {},
                        children: [
                          ExpansionPanel(
                            headerBuilder: (context, isExpanded) {
                              return ListTile(
                                title: Text(
                                  'Order Items (${cartItems.length})',
                                  style: GoogleFonts.nunito(
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              );
                            },
                            body: Column(
                              children: cartItems
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => _buildCartItemCard(
                                      entry.value,
                                      isMobile,
                                      screenWidth,
                                      screenHeight,
                                    ),
                                  )
                                  .toList(),
                            ),
                            isExpanded: true,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
                      child: Text(
                        'Order Summary',
                        style: GoogleFonts.nunito(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.borderColor,
                        ),
                      ),
                    ),
                    const DeliveryInstructionsSection(),
                    ...cartItems.asMap().entries.map((entry) {
                      final item = entry.value;
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8.0 : 16.0,
                          vertical: 4.0,
                        ),
                        child: BillItem(
                          amountColor: const Color(0xFF273847),
                          title: item.name,
                          amount:
                              '₹${(item.price * item.quantity).toStringAsFixed(0)} /-',
                          isRightAligned: true,
                          isBold: false,
                        ),
                      );
                    }),
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
                      child: BillItem(
                        amountColor: const Color(0xFF273847),
                        title: 'Total',
                        amount:
                            '₹${cartItems.fold(0.0, (sum, item) => sum + item.price * item.quantity).toStringAsFixed(0)} /-',
                        isRightAligned: true,
                        isBold: true,
                      ),
                    ),
                    SizedBox(height: isMobile ? 80 : 100),
                  ],
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load cart items: $error'),
              backgroundColor: Colors.red,
            ),
          );
          return Center(
            child: Text(
              'Error: $error',
              style: GoogleFonts.nunito(
                fontSize: isMobile ? 16 : 20,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: cartAsync.when(
        data: (cartItems) => cartItems.isEmpty
            ? null
            : Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16.0 : 24.0,
                  vertical: isMobile ? 12.0 : 16.0,
                ),
                color: Colors.white,
                child: ElevatedButton(
                  onPressed: isPaymentLoading
                      ? null
                      : () async {
                          ref.refresh(paymentMethodProvider);
                          ref.read(paymentLoadingProvider.notifier).state =
                              true;

                          final totalAmount = cartItems.fold(
                            0.0,
                            (sum, item) => sum + item.price * item.quantity,
                          );

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setDouble(
                            'totalAmountToPay',
                            totalAmount,
                          );

                          context.push('/OrderConfirmation');

                          ref.read(paymentLoadingProvider.notifier).state =
                              false;
                          ref.refresh(CODloadingProvider);
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPaymentLoading
                        ? Colors.grey
                        : AppColors.primaryColor,

                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 12.0 : 16.0,
                      horizontal: isMobile ? 24.0 : 32.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isPaymentLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.payment, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Pay Now',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: isMobile ? 12 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildCartItemCard(
    SharedPreferencesCartItem item,
    bool isMobile,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: isMobile ? 12.0 : 16.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.imageUrls.isNotEmpty
                      ? CachedNetworkImage(
                          width: screenWidth * (isMobile ? 0.22 : 0.14),
                          height: screenWidth * (isMobile ? 0.22 : 0.14),
                          fit: BoxFit.cover,
                          imageUrl: item.imageUrls[0],
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: AppColors.primaryColor,
                            highlightColor: Colors.white,
                            child: Container(
                              width: screenWidth * (isMobile ? 0.22 : 0.14),
                              height: screenWidth * (isMobile ? 0.22 : 0.14),
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: screenWidth * (isMobile ? 0.22 : 0.14),
                            height: screenWidth * (isMobile ? 0.22 : 0.14),
                            color: AppColors.primaryColor,
                            child: const Icon(
                              Icons.error,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                          ),
                        )
                      : Container(
                          width: screenWidth * (isMobile ? 0.22 : 0.14),
                          height: screenWidth * (isMobile ? 0.22 : 0.14),
                          color: AppColors.primaryColor,
                          child: const Icon(
                            Icons.image,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                        ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryColor,
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Text(
                        '₹${item.price.toStringAsFixed(0)} /-',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryColor,
                          fontSize: isMobile ? 13 : 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Quantity: ${item.quantity}',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryColor,
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
