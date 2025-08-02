import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriesProvider = StreamProvider<List<String>>((ref) {
  return FirebaseFirestore.instance
      .collection('Categories')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => doc['category'] as String).toList(),
      );
});

final productFormProvider = StateProvider<ProductFormState>(
  (ref) => ProductFormState(),
);

class ProductFormState {
  final String name;
  final String color;
  final String category;
  final String description;
  final double price;
  final int quantity;
  final List<PlatformFile> images;

  ProductFormState({
    this.name = '',
    this.color = '',
    this.category = '',
    this.description = '',
    this.price = 0.0,
    this.quantity = 0,
    this.images = const [],
  });

  ProductFormState copyWith({
    String? name,
    String? color,
    String? category,
    String? description,
    double? price,
    int? quantity,
    List<PlatformFile>? images,
  }) {
    return ProductFormState(
      name: name ?? this.name,
      color: color ?? this.color,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      images: images ?? this.images,
    );
  }
}
