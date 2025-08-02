import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Services/Guest_Alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ordersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) async* {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email') ?? '';
  if (email.isEmpty) {
    yield [];
    return;
  }
  final query = FirebaseFirestore.instance
      .collection('orders')
      .where('email', isEqualTo: email)
      .snapshots();

  await for (final snapshot in query) {
    final orders = snapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();
    yield orders;
  }
});

class OrdersTabScreen extends ConsumerWidget {
  const OrdersTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          "My Orders",
          style: GoogleFonts.nunito(
            fontSize: 25,
            color: AppColors.primaryColor,
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          final email = snapshot.data!.getString('email') ?? '';

          if (email.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Please log in to view your orders',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: AppColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      LoginBottomSheet.checkAndShow(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Login to view orders',
                      style: GoogleFonts.nunito(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }
          return ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No orders found',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: AppColors.backgroundColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final items = List<Map<String, dynamic>>.from(
                    order['items'] ?? [],
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(
                        'Order ID: #${order['id']}',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.borderColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.borderColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          order['status'] ?? 'Pending',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      collapsedBackgroundColor: AppColors.footercolor,
                      backgroundColor: AppColors.footercolor,
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderColor),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderColor),
                      ),
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      childrenPadding: const EdgeInsets.only(bottom: 8),
                      children: items.map((item) {
                        final imageUrls = List<String>.from(
                          item['imageUrls'] ?? [],
                        );
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: imageUrls.isNotEmpty
                                    ? Image.network(
                                        imageUrls[0],
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => Container(
                                              width: 90,
                                              height: 90,
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 50,
                                                color: AppColors.borderColor,
                                              ),
                                            ),
                                      )
                                    : Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: AppColors.borderColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: AppColors.borderColor,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? 'Unknown Item',
                                      style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Quantity: ${item['quantity'] ?? 1}',
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      'Price: ₹${item['price']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error loading orders: $error',
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }
}
