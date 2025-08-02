import 'package:bowsandties/Admin/Pages/AddCategoryPage.dart';
import 'package:bowsandties/Admin/Pages/Add_Product.dart';
import 'package:bowsandties/Admin/Pages/All_Categories.dart';
import 'package:bowsandties/Admin/Pages/All_Products.dart';
import 'package:bowsandties/Admin/Pages/Orders.dart';
import 'package:bowsandties/Admin/Pages/Past_Orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final sidebarPageIndexProvider = StateProvider<int>((ref) => 0);

class CustomSidebarLayout extends ConsumerWidget {
  const CustomSidebarLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(sidebarPageIndexProvider);
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.home_outlined,
        'title': 'Add Product',
        'widget': const AddProductPage(),
      },
      {
        'icon': Icons.add_business_outlined,
        'title': 'Add Category',
        'widget': const AddCategoryPage(),
      },
      {
        'icon': Icons.all_inbox_rounded,
        'title': 'All Category',
        'widget': const ViewCategoriesPage(),
      },
      {
        'icon': Icons.delivery_dining,
        'title': 'Orders',
        'widget': const OrderManagementPage(),
      },
      {
        'icon': Icons.check_circle_outline,
        'title': 'Past Orders',
        'widget': const DeliveredOrdersPage(),
      },
      {
        'icon': Icons.shopify_sharp,
        'title': 'Products',
        'widget': const ProductListPage(),
      },
    ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Row(
            children: [
              Container(
                width: isMobile ? 70 : 220,
                color: Colors.black,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      if (!isMobile)
                        Center(
                          child: Text(
                            'Bows & Ties',
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: ListView(
                          children: menuItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;

                            return InkWell(
                              onTap: () {
                                ref
                                        .read(sidebarPageIndexProvider.notifier)
                                        .state =
                                    index;
                              },
                              child: Container(
                                color: selectedIndex == index
                                    ? Colors.grey[800]
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment: isMobile
                                      ? MainAxisAlignment.center
                                      : MainAxisAlignment.start,
                                  children: [
                                    Icon(item['icon'], color: Colors.white),
                                    if (!isMobile) ...[
                                      const SizedBox(width: 12),
                                      Text(
                                        item['title'],
                                        style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey[100],
                  child: menuItems[selectedIndex]['widget'] as Widget,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
