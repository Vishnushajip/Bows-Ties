import 'package:bowsandties/Components/Cart_Container.dart';
import 'package:bowsandties/Feedback/Display_feedback.dart';
import 'package:bowsandties/Feedback/Landing_Feedback_alert.dart';
import 'package:bowsandties/Landing/Appbar.dart';
import 'package:bowsandties/Landing/Carousel.dart';
import 'package:bowsandties/Landing/Categories.dart';
import 'package:bowsandties/Landing/Footer.dart';
import 'package:bowsandties/Landing/Insta_page.dart';
import 'package:bowsandties/Landing/Myprofile.dart';
import 'package:bowsandties/Landing/Watch&Shop.dart';
import 'package:bowsandties/Services/ContactMenuButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Serach_bar.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FeedbackBottomSheet.checkAndShowIfEligible(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Column(children: [ResponsiveCard(), SearchInput()]),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const CarouselSliderWidget(),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: isMobile ? 250 : 300,
                    child: const CategoryScreen(),
                  ),
                  const SizedBox(height: 20),
                  const WatchAndShop(),
                  const SizedBox(height: 20),
                  InstagramPostsWeb(),
                  const SizedBox(height: 20),
                  const FeedbackView(),
                  const SizedBox(height: 20),
                  const Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: const CartContainer(),
      floatingActionButton: const ContactMenuButton(),
    );
  }
}
