import 'package:bowsandties/Cart/Provider/cartProvider.dart';
import 'package:bowsandties/Components/App_Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final paymentLoadingProvider = StateProvider<bool>((ref) => false);

class OrderSummaryPage extends ConsumerWidget {
  const OrderSummaryPage({super.key});

  Future<Map<String, String>> _getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final addressList = prefs.getStringList('selected_address');

    if (addressList != null && addressList.length >= 6) {
      return {
        'name': addressList[0],
        'address': addressList[1],
        'phoneNumber': addressList[2],
        'pincode': addressList[3],
        'type': addressList[4],
        'email': addressList[5],
      };
    } else {
      return {
        'name': 'Unknown',
        'address': 'No address provided',
        'phoneNumber': 'No phone number',
        'pincode': 'No pincode',
        'type': 'No type',
        'email': 'No email',
      };
    }
  }

  Future<double> _getTotalAmount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('totalAmountToPay') ?? 0.0;
  }

  Future<String> _getdeliveryInstructions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('deliveryInstructions') ?? "";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Order Summary',
            style: GoogleFonts.pacifico(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        cartAsync.when(
          data: (cartItems) => cartItems.isEmpty
              ? Text(
                  'No items in cart',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                )
              : Column(
                  children: cartItems
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.imageUrls.isNotEmpty
                                    ? Image.network(
                                        item.imageUrls[0],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 80,
                                                  color: Colors.grey,
                                                ),
                                      )
                                    : const Icon(
                                        Icons.image_not_supported,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Quantity: ${item.quantity}',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
          loading: () => const CircularProgressIndicator(
            color: AppColors.primaryColor,
            strokeAlign: 1,
          ),
          error: (error, stack) => Text(
            'Error loading cart: $error',
            style: GoogleFonts.nunito(fontSize: 16, color: Colors.red),
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<double>(
          future: _getTotalAmount(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                color: AppColors.primaryColor,
                strokeAlign: 1,
              );
            }
            return Text(
              'Total Amount: ₹${snapshot.data?.toStringAsFixed(0) ?? '0.00'}/-',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, String>>(
          future: _getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                color: AppColors.primaryColor,
                strokeAlign: 1,
              );
            }
            final userDetails = snapshot.data ?? {};
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Address',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${userDetails['name']}\n${userDetails['address']}\n${userDetails['pincode']}\n${userDetails['phoneNumber']}\n${userDetails['type']}\n${userDetails['email']}',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        FutureBuilder<String>(
          future: _getdeliveryInstructions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                color: AppColors.primaryColor,
                strokeAlign: 1,
              );
            }
            final instructions = snapshot.data;
            if (instructions == null || instructions.trim().isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    FontAwesomeIcons.pen,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Instructions',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${snapshot.data}',
                          style: GoogleFonts.nunito(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
