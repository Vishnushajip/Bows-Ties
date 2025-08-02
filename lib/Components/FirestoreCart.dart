import 'dart:convert';

import 'package:bowsandties/Services/Utlies.dart/TimeStamp.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesCartItem {
  final String id;
  final String name;
  final String Color;
  final double view;
  final double price;
  final List<String> imageUrls;
  final String category;
  final String desc;
  final DateTime timestamp;
  int quantity;

  SharedPreferencesCartItem({
    required this.id,
    required this.name,
    required this.Color,
    required this.price,
    required this.desc,
    required this.view,
    required this.imageUrls,
    required this.category,
    required this.timestamp,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'view': view,
    'imageUrls': imageUrls,
    'category': category,
    'timestamp': timestamp.toIso8601String(),
    'quantity': quantity,
    'desc': desc,
    'Color': Color,
  };

  factory SharedPreferencesCartItem.fromJson(Map<String, dynamic> json) {
    return SharedPreferencesCartItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      Color: json['Color'] ?? '',
      desc: json['desc'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      view: (json['view'] as num?)?.toDouble() ?? 0.0,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      category: json['category'] ?? '',
      timestamp: parseTimestamp(json['timestamp']),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class SharedPreferencesCartNotifier
    extends StateNotifier<List<SharedPreferencesCartItem>> {
  SharedPreferencesCartNotifier() : super([]) {
    loadCartItems();
  }

  Future<void> loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? cartItemsJson = prefs.getStringList('cartItems');

    if (cartItemsJson != null) {
      state = cartItemsJson.map((itemJson) {
        return SharedPreferencesCartItem.fromJson(jsonDecode(itemJson));
      }).toList();
    } else {
      state = [];
    }
  }

  Future<void> saveCartState() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = state
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList('cartItems', cartItemsJson);
  }

  void addItemToCart(SharedPreferencesCartItem item) async {
    state = [...state, item];

    await saveCartState();
  }

  void increaseItemQuantity(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index >= 0) {
      state[index].quantity++;
      state = [...state];
      await saveCartState();
    }
  }

  void decreaseItemQuantity(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (state[index].quantity > 1) {
        state[index].quantity--;
        state = [...state];
        await saveCartState();
      } else {
        removeItemFromCart(id);
      }
    }
  }

  void removeItemFromCart(String id) async {
    state = state.where((item) => item.id != id).toList();
    await saveCartState();
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cartItems');
    state = [];
    print("Cart has been cleared successfully.");
  }
}

final sharedPreferencesCartProvider =
    StateNotifierProvider<
      SharedPreferencesCartNotifier,
      List<SharedPreferencesCartItem>
    >((ref) {
      return SharedPreferencesCartNotifier();
    });
