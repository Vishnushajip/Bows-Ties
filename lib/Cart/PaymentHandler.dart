import 'dart:async';
import 'dart:math';

import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:bowsandties/Services/StockReducer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentHandler {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> generateOrderId() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int randomNum = Random().nextInt(900000) + 100000;
    String orderId = '$randomNum$timestamp';
    return orderId.substring(orderId.length - 5);
  }

  Future<void> clearCart(WidgetRef ref) async {
    final cartItems = ref.read(sharedPreferencesCartProvider);
    if (cartItems.isNotEmpty) {
      ref.read(sharedPreferencesCartProvider.notifier).clearCart();
      print("All items have been removed from the cart.");
    } else {
      print("The cart is already empty.");
    }
  }

  Future<void> saveOrderDetails(WidgetRef ref) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedAddress = prefs.getStringList('selected_address');
      final deliveryInstructions = prefs.getString('deliveryInstructions');

      if (selectedAddress == null || selectedAddress.length < 6) {
        throw Exception("No selected address found in SharedPreferences.");
      }

      final name = selectedAddress[0];
      final address = selectedAddress[1];
      final phoneNumber = selectedAddress[2];
      final pincode = selectedAddress[3];
      final type = selectedAddress[4];
      final email = selectedAddress[5];

      final cartItems = ref.read(sharedPreferencesCartProvider);
      final orderId = await generateOrderId();

      final orderData = {
        'orderId': orderId,
        'email': email,
        'name': name,
        'address': address,
        'phoneNumber': phoneNumber,
        'pincode': pincode,
        'deliveryInstructions': deliveryInstructions,
        'status': "Order Placed",
        'type': type,
        'items': cartItems
            .map(
              (item) => {
                'name': item.name,
                'price': item.price,
                'quantity': item.quantity,
                'imageUrls': item.imageUrls,
              },
            )
            .toList(),
        'totalAmount': cartItems.fold<double>(
          0.0,
          (sum, item) => sum + item.price * item.quantity,
        ),
        'timestamp': DateTime.now().toIso8601String(),
      };

      await firestore.collection('orders').doc(orderId).set(orderData);
      final reducer = StockReducer(
        firestore: FirebaseFirestore.instance,
        collectionName: 'Products',
      );

      for (final item in cartItems) {
        await reducer.reduceItemStock(
          fieldValue: item.name,
          quantityOrdered: item.quantity,
        );
      }

      print(
        "Order details saved successfully to Firestore with orderId: $orderId",
      );
      await clearCart(ref);
    } catch (e) {
      print("Error saving order details: $e");
      rethrow;
    }
  }
}
