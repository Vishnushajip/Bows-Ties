import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentIndexProvider = StateProvider<int>((ref) => 0);
final carouselProvider = FutureProvider<List<SharedPreferencesCartItem>>((
  ref,
) async {
  final firestore = FirebaseFirestore.instance;

  final querySnapshot = await firestore
      .collection('Products')
      .orderBy('timestamp', descending: true)
      .limit(5)
      .get();

  return querySnapshot.docs.map((doc) {
    final data = doc.data();
    return SharedPreferencesCartItem.fromJson(data);
  }).toList();
});
