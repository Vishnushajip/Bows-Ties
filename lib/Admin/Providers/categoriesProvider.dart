import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriesStreamProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('Categories')
      .orderBy('timestamp', descending: true)
      .snapshots();
});

final deletingDocsProvider =
    StateNotifierProvider<DeletingDocsNotifier, Set<String>>(
  (ref) => DeletingDocsNotifier(),
);

class DeletingDocsNotifier extends StateNotifier<Set<String>> {
  DeletingDocsNotifier() : super({});

  void add(String id) => state = {...state, id};
  void remove(String id) => state = {...state}..remove(id);
}
