import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class Product {
  final String id;
  final String name;
  final String color;
  final String category;
  final String desc;
  final double price;
  final int quantity;
  final List<String> imageUrls;
  final String timestamp;

  Product({
    required this.id,
    required this.name,
    required this.color,
    required this.category,
    required this.desc,
    required this.price,
    required this.quantity,
    required this.imageUrls,
    required this.timestamp,
  });

  factory Product.fromMap(Map<String, dynamic> data) => Product(
    id: data['id'],
    name: data['name'],
    color: data['color'],
    category: data['category'],
    desc: data['desc'],
    price: (data['price'] as num).toDouble(),
    quantity: (data['quantity'] as num).toInt(),
    imageUrls: List<String>.from(data['imageUrls']),
    timestamp: data['timestamp'],
  );
}

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<Product>>(
      ProductListNotifier.new,
    );

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  final int _limit = 10;
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  @override
  Future<List<Product>> build() async {
    return _fetchInitial();
  }

  Future<List<Product>> _fetchInitial() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Products')
        .orderBy('timestamp', descending: true)
        .limit(_limit)
        .get();
    _lastDoc = snapshot.docs.lastOrNull;
    return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    state = await AsyncValue.guard(() async {
      final snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(_limit)
          .get();

      if (snapshot.docs.length < _limit) _hasMore = false;
      if (snapshot.docs.isEmpty) return state.value ?? [];

      _lastDoc = snapshot.docs.last;
      final newItems = snapshot.docs
          .map((doc) => Product.fromMap(doc.data()))
          .toList();
      return [...(state.value ?? []), ...newItems];
    });
  }

  Future<void> deleteProduct(String id) async {
    await FirebaseFirestore.instance.collection('Products').doc(id).delete();
    state = AsyncValue.data(
      (state.value ?? []).where((p) => p.id != id).toList(),
    );
  }
}

class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    final notifier = ref.read(productListProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "All Products",
          style: GoogleFonts.nunito(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: productsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (e, _) => Center(
          child: Text("Error: $e", style: const TextStyle(color: Colors.black)),
        ),
        data: (products) => NotificationListener<ScrollNotification>(
          onNotification: (scroll) {
            if (scroll.metrics.pixels == scroll.metrics.maxScrollExtent) {
              notifier.loadMore();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  context.push('/ProductDetailPage', extra: product);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: product.imageUrls.isNotEmpty
                        ? Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.imageUrls.first,
                                fit: BoxFit.fill,
                              ),
                            ),
                          )
                        : const Icon(Icons.image, color: Colors.black),
                    title: Text(
                      product.name,
                      style: GoogleFonts.nunito(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      product.category,
                      style: GoogleFonts.nunito(color: Colors.black),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: () {
                            context.push('/editproduct', extra: product);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () =>
                              _confirmDelete(context, product, notifier),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Product product,
    ProductListNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete ${product.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      notifier.deleteProduct(product.id);
    }
  }
}
