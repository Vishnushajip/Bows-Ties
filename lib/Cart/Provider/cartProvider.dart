import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final cartProvider = FutureProvider<List<SharedPreferencesCartItem>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final cartItems = <SharedPreferencesCartItem>[];
  int i = 0;
  while (prefs.getString('item_name_$i') != null) {
    final name = prefs.getString('item_name_$i') ?? 'Unknown';
    final quantity = prefs.getInt('item_quantity_$i') ?? 1;
    final price = prefs.getDouble('item_price_$i') ?? 0.0;
    final imageUrl = prefs.getString('item_imageUrl_$i') ?? '';

    cartItems.add(
      SharedPreferencesCartItem(
        name: name,
        quantity: quantity,
        price: price,
        imageUrls: imageUrl.isNotEmpty ? [imageUrl] : [],
        id: '', 
        view: 0,
        category: '',
        timestamp: DateTime.now(),
        desc: '',
        Color: '',
      ),
    );
    i++;
  }
  return cartItems;
});

final paymentLoadingProvider = StateProvider<bool>((ref) => false);