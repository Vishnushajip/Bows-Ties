import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:bowsandties/Services/Utlies.dart/TimeStamp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchPropertyProvider =
    FutureProvider.family<List<SharedPreferencesCartItem>, String>((
      ref,
      query,
    ) async {
      if (query.trim().isEmpty) return [];

      final lowercaseQuery = query.trim().toLowerCase();

      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('Products')
            .get();

        final filteredDocs = snapshot.docs.where((doc) {
          final data = doc.data();
          final name = data['name']?.toString().toLowerCase() ?? '';
          return name.contains(lowercaseQuery);
        }).toList();

        return filteredDocs.map((doc) {
          final data = doc.data();

          return SharedPreferencesCartItem(
            id: doc.id,
            name: data['name'] ?? 'Unknown',
            price: double.tryParse(data['price']?.toString() ?? '0.0') ?? 0.0,
            view: data['view'] ?? 0,
            imageUrls: (data['imageUrls'] as List?)?.cast<String>() ?? [],
            category: data['category'] ?? '',
            timestamp: parseTimestamp(data['timestamp']),
            quantity: data['quantity'] ?? 1,
            desc: data['desc'] ?? '',
            Color: data['Color'] ?? '',
          );
        }).toList();
      } catch (e) {
        rethrow;
      }
    });
