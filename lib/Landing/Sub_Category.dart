import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:bowsandties/Components/Grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Services/Utlies.dart/TimeStamp.dart';

final productsProvider =
    FutureProvider.family<List<SharedPreferencesCartItem>, String>((
      ref,
      category,
    ) async {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Products')
          .where('category', isEqualTo: category)
          .where("quantity", isGreaterThan: 0)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return SharedPreferencesCartItem(
          id: doc.id,
          name: data['name'] ?? '',
          price: (data['price'] is num)
              ? (data['price'] as num).toDouble()
              : 0.0,
          view: data['view'] ?? 0,
          imageUrls: List<String>.from(data['imageUrls'] ?? []),
          category: data['category'] ?? '',
          timestamp: parseTimestamp(data['timestamp']),
          quantity: data['quantity'] ?? 0,
          desc: data['desc'] ?? '',
          Color: data['Color'] ?? '',
        );
      }).toList();
    });

class ProductsPage extends ConsumerWidget {
  final String category;

  const ProductsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider(category));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          '$category Products',
          style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: productsAsync.when(
        data: (products) => LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 800;

            const double minCardWidth = 200.0;
            const double spacing = 16.0;
            final int columns = isMobile
                ? (screenWidth / (minCardWidth + spacing)).floor().clamp(2, 2)
                : (screenWidth / (minCardWidth + spacing)).floor().clamp(2, 4);

            final cardWidth =
                (screenWidth - (spacing * (columns - 1)) - 32) / columns;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.start,
                children: products.map((product) {
                  return SizedBox(
                    width: cardWidth,
                    child: PropertyCard(
                      data: product,
                      onTap: () {
                        context.push('/ProductDetails', extra: product);
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
            strokeAlign: 1,
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading products: $error',
            style: GoogleFonts.nunito(fontSize: 16, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
