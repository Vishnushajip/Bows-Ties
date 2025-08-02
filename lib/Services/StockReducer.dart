import 'package:cloud_firestore/cloud_firestore.dart';

class StockReducer {
  final FirebaseFirestore firestore;
  final String collectionName;

  StockReducer({required this.firestore, required this.collectionName});

  Future<void> reduceItemStock({
    required dynamic fieldValue,
    required int quantityOrdered,
  }) async {
    try {
      final querySnapshot = await firestore
          .collection(collectionName)
          .where("name", isEqualTo: fieldValue)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print(
          "Item with $fieldValue not found in $collectionName.",
        );
        return;
      }

      final doc = querySnapshot.docs.first;
      final currentQty = (doc['quantity'] as num).toInt();
      final newQty = currentQty - quantityOrdered;

      if (newQty < 0) {
        print("Insufficient stock. Cannot reduce below 0 for $fieldValue.");
        return;
      }

      await doc.reference.update({'quantity': newQty});
      print("Stock reduced successfully to $newQty for $fieldValue.");
    } catch (e) {
      print("Error reducing stock: $e");
    }
  }
}
