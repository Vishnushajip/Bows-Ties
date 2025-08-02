import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final averageRatingProvider =
    FutureProvider.family<double, String>((ref, productId) async {
  final doc = await FirebaseFirestore.instance
      .collection('Products')
      .doc(productId)
      .get();

  if (doc.exists && doc.data() != null) {
    final data = doc.data()!;
    return (data['averageRating'] as num?)?.toDouble() ?? 0.0;
  } else {
    return 0.0;
  }
});
