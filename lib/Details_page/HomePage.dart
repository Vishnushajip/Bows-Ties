import 'package:bowsandties/Cart/Add_cart.dart';
import 'package:bowsandties/Components/Cart_Container.dart';
import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:bowsandties/Details_page/Desc.dart';
import 'package:bowsandties/Details_page/Header.dart';
import 'package:bowsandties/Details_page/Suggetions.dart';
import 'package:bowsandties/Landing/Footer.dart';
import 'package:bowsandties/Landing/Watch&Shop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends ConsumerWidget {
  final SharedPreferencesCartItem menuItem;
  const HomePage({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    final isVisible = ref.watch(cartVisibilityProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          menuItem.name,
          style: GoogleFonts.nunito(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ImageHeader(menuItem: menuItem),
                SizedBox(height: screenHeight * 0.03),
                Transform.translate(
                  offset: Offset(0, -screenHeight * 0.05),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      width: screenWidth,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Suggestions(menuItem: menuItem),
                            CartActionButtons(menuItem: menuItem),
                            SizedBox(height: screenHeight * 0.02),
                            Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
                            ),

                            Description(menuItem: menuItem),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const WatchAndShop(),
                SizedBox(height: screenHeight * 0.02),
                const Footer(),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: cartItems.isNotEmpty && isVisible
          ? AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const CartContainer(),
            )
          : null,
    );
  }
}
