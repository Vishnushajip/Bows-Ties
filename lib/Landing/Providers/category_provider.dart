import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Category {
  final String name;
  final String? imageUrl;

  Category({required this.name, this.imageUrl});

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      name: data['category'] ?? '',
      imageUrl: data['imageUrl'] as String?,
    );
  }
}

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('Categories')
      .get();

  return querySnapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
});
