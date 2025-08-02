import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:bowsandties/Services/Utlies.dart/TimeStamp.dart';
import 'package:bowsandties/Services/share/Share_whatsapp.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

final productDetailProvider =
    FutureProvider.family<SharedPreferencesCartItem, String>((
      ref,
      productId,
    ) async {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Products')
          .doc(productId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Product with ID $productId not found');
      }

      final data = docSnapshot.data()!;
      return SharedPreferencesCartItem(
        id: docSnapshot.id,
        name: data['name'] ?? '',
        price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
        view: data['view'] ?? 0,
        imageUrls: List<String>.from(data['imageUrls'] ?? []),
        category: data['category'] ?? '',
        timestamp: parseTimestamp(data['timestamp']),
        quantity: data['quantity'] ?? 0,
        desc: data['desc'] ?? '',
        Color: data['color'] ?? '',
      );
    });

class ProductDetailsPage extends ConsumerWidget {
  final String Id;

  const ProductDetailsPage({super.key, required this.Id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(Id));

    return WillPopScope(
      onWillPop: () async {
        GoRouter.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.pinkAccent),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Product Details",
            style: GoogleFonts.pacifico(color: Colors.pinkAccent, fontSize: 24),
          ),
          backgroundColor: Colors.pink[50],
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: productAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.pinkAccent),
          ),
          error: (e, _) => Center(
            child: Text(
              'Error loading product: $e',
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.redAccent),
            ),
          ),
          data: (product) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.imageUrls.isNotEmpty)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink[100]!.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: PageView.builder(
                      itemCount: product.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: product.imageUrls[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.pink[100]!,
                                highlightColor: Colors.pink[50]!,
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.pink[100]!, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: GoogleFonts.pacifico(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.pink[700],
                                      ),
                                    ),
                                    Text(
                                      "Category: ${product.category}",
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        color: Colors.pink[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Material(
                                color: Colors.pink[200],
                                shape: const CircleBorder(),
                                child: IconButton(
                                  icon: const Icon(
                                    FontAwesomeIcons.share,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    sharePropertyOnWhatsApp(
                                      imageUrl: product.imageUrls.isNotEmpty
                                          ? product.imageUrls[0]
                                          : '',
                                      name: product.name,
                                      price: product.price.toString(),
                                      Id: product.id,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Price",
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.pink[400],
                                    ),
                                  ),
                                  Text(
                                    "₹${product.price.toStringAsFixed(2)}",
                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.pink[700],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Quantity",
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.pink[400],
                                    ),
                                  ),
                                  Text(
                                    product.quantity.toString(),
                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.pink[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Views",
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.pink[400],
                                    ),
                                  ),
                                  Text(
                                    product.view.toString(),
                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.pink[700],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Listed On",
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.pink[400],
                                    ),
                                  ),
                                  Text(
                                    "${product.timestamp.day}/${product.timestamp.month}/${product.timestamp.year}",

                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.pink[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Color",
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.pink[400],
                                    ),
                                  ),
                                  Text(
                                    product.Color,
                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.pink[700],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Category",
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Colors.pink[400],
                                    ),
                                  ),
                                  Text(
                                    product.category,
                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.pink[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Product Description",
                            style: GoogleFonts.pacifico(
                              color: Colors.pink[700],
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            product.desc,
                            style: GoogleFonts.nunito(
                              color: Colors.pink[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
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
