import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchAndShopViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _pageSize = 50;
  DocumentSnapshot? _lastDocument;

  Future<List<SharedPreferencesCartItem>> fetchProducts({
    bool loadMore = false,
  }) async {
    Query query = _firestore
        .collection('Products')
        .orderBy('timestamp', descending: true)
        .limit(_pageSize);

    if (loadMore && _lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastDocument = querySnapshot.docs.last;
    }

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return SharedPreferencesCartItem.fromJson(data);
    }).toList();
  }
}

final watchAndShopViewModelProvider = Provider<WatchAndShopViewModel>((ref) {
  return WatchAndShopViewModel();
});

final productsProvider =
    StateNotifierProvider<
      ProductsNotifier,
      AsyncValue<List<SharedPreferencesCartItem>>
    >((ref) {
      return ProductsNotifier(ref);
    });

class ProductsNotifier
    extends StateNotifier<AsyncValue<List<SharedPreferencesCartItem>>> {
  final Ref _ref;
  List<SharedPreferencesCartItem> _allProducts = [];

  ProductsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _fetchInitialProducts();
  }

  Future<void> _fetchInitialProducts() async {
    state = const AsyncValue.loading();
    try {
      final viewModel = _ref.read(watchAndShopViewModelProvider);
      final products = await viewModel.fetchProducts();
      _allProducts = products;
      state = AsyncValue.data(_allProducts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void refresh() {
    _allProducts = [];
    _fetchInitialProducts();
  }
}
