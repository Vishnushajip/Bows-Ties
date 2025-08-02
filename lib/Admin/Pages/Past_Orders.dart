import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Services/Scaffold_Messanger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

final deliveredOrdersProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return FirebaseFirestore.instance
      .collection('orders')
      .where('status', isEqualTo: 'Order Delivered')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
      );
});

class DeliveredOrdersPage extends ConsumerWidget {
  const DeliveredOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(deliveredOrdersProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Delivered Orders', style: GoogleFonts.nunito()),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ordersAsync.when(
          data: (orders) => orders.isEmpty
              ? const Center(
                  child: Text('No orders found with status "Order Delivered"'),
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  FontAwesomeIcons.whatsapp,
                                  color: Colors.green,
                                ),
                                onPressed: () =>
                                    _openWhatsAppChat(context, order),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _deleteOrder(context, order['id']),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                  Text(
                                    'Status: ${order['status']}',
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
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeAlign: .05,
            ),
          ),
          error: (error, stackTrace) {
            _logErrorToFirestore(error, stackTrace);
            return Center(child: Text('Error: $error'));
          },
        ),
      ),
    );
  }

  Future<void> _logErrorToFirestore(
    Object error,
    StackTrace? stackTrace,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('errors').add({
        'error': error.toString(),
        'stackTrace': stackTrace?.toString() ?? 'No stack trace available',
        'timestamp': DateTime.now().toIso8601String(),
        'context':
            'DeliveredOrdersPage - fetching orders with status Order Delivered',
      });
    } catch (e) {
      debugPrint('Failed to log error to Firestore: $e');
    }
  }

  Future<void> _openWhatsAppChat(
    BuildContext context,
    Map<String, dynamic> order,
  ) async {
    final phoneNumber = order['phoneNumber'] as String;
    final orderId = order['orderId'] as String;
    final items = order['items'] as List<dynamic>;

    final itemsText = items
        .asMap()
        .entries
        .map((entry) {
          final item = entry.value as Map<String, dynamic>;
          return 'Item ${entry.key + 1}: ${item['name']} (Qty: ${item['quantity']}, Price: ₹${item['price']})';
        })
        .join('\n');
    final feedbackUrl = 'https://bowsandties.in/feedback?orderId=$orderId';

    final message = Uri.encodeComponent(
      '✨ Hello ${order['name']}! ✨\n\n'
      '🎀 Your order (ID: $orderId) has arrived at your doorstep! 🎀\n\n'
      'Here’s what’s inside your pretty package:\n$itemsText\n\n'
      '💖 We’d absolutely LOVE to hear your thoughts,💖\n\n'
      'Tell us how we did (and which HariBand is your new fave! 😍) with a quick review:\n$feedbackUrl\n\n'
      'P.S. Tag us in your #HariBand selfies for a chance to be featured! 📸✨',
    );

    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$message';

    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening WhatsApp: $e')));
    }
  }

  Future<void> _deleteOrder(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(docId).delete();
      CustomMessenger(
        context: context,
        message: "Order deleted successfully",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting order: $e')));
    }
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
                    'Price: \$${item['price']}',
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
