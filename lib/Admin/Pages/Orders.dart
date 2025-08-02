import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Services/Scaffold_Messanger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final ordersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('orders')
      .where('status', isEqualTo: 'Order Placed')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
      );
});

class OrderManagementPage extends ConsumerWidget {
  const OrderManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Order Management',
          style: GoogleFonts.nunito(color: AppColors.primaryColor),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ordersAsync.when(
          data: (orders) => orders.isEmpty
              ? const Center(
                  child: Text('No orders found with status "Order Placed"'),
                )
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                          expansionTileTheme: const ExpansionTileThemeData(
                            backgroundColor: Colors.white,
                            collapsedBackgroundColor: Colors.white,
                          ),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            'Order ID: ${order['orderId']}',
                            style: GoogleFonts.nunito(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          subtitle: Text(
                            'Customer: ${order['name']}',
                            style: GoogleFonts.nunito(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStatusDropdown(
                                    context,
                                    ref,
                                    order['id'],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Address: ${order['address']}',
                                    style: GoogleFonts.nunito(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Email: ${order['email']}',
                                    style: GoogleFonts.nunito(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Phone: ${order['phoneNumber']}',
                                    style: GoogleFonts.nunito(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Pincode: ${order['pincode']}',
                                    style: GoogleFonts.nunito(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Total Amount: ₹${order['totalAmount']}',
                                    style: GoogleFonts.nunito(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Timestamp: ${order['timestamp']}',
                                    style: GoogleFonts.nunito(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Items:',
                                    style: GoogleFonts.nunito(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  ..._buildItemsList(order['items']),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(
    BuildContext context,
    WidgetRef ref,
    String docId,
  ) {
    return DropdownButton<String>(
      value: 'Order Placed',
      items: [
        DropdownMenuItem(
          value: 'Order Placed',
          child: Text(
            'Order Placed',
            style: GoogleFonts.nunito(color: AppColors.primaryColor),
          ),
        ),
        DropdownMenuItem(
          value: 'Order Delivered',
          child: Text(
            'Order Delivered',
            style: GoogleFonts.nunito(color: AppColors.primaryColor),
          ),
        ),
      ],
      onChanged: (value) async {
        if (value == 'Order Delivered') {
          try {
            await FirebaseFirestore.instance
                .collection('orders')
                .doc(docId)
                .update({'status': 'Order Delivered'});
            CustomMessenger(
              context: context,
              message: "Status updated to Order Delivered",
              backgroundColor: Colors.green,
              textColor: Colors.white,
            ).show;
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating status: $e')),
            );
          }
        }
      },
      hint: Text('Update Status', style: GoogleFonts.nunito()),
    );
  }

  List<Widget> _buildItemsList(List<dynamic> items) {
    return items.asMap().entries.map((entry) {
      final item = entry.value as Map<String, dynamic>;
      final imageUrl = (item['imageUrls'] as List<dynamic>).isNotEmpty
          ? item['imageUrls'][0]
          : null;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image on the left
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported),
              ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item ${entry.key + 1}',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Text(
                    'Name: ${item['name']}',
                    style: GoogleFonts.nunito(color: AppColors.primaryColor),
                  ),
                  Text(
                    'Price: ₹${item['price']}',
                    style: GoogleFonts.nunito(color: AppColors.primaryColor),
                  ),
                  Text(
                    'Quantity: ${item['quantity']}',
                    style: GoogleFonts.nunito(color: AppColors.primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
