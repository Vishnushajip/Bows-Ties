import 'package:bowsandties/Address/Pages/Add_Address.dart';
import 'package:bowsandties/Address/Pages/All_Address.dart';
import 'package:bowsandties/Admin/Pages/All_Products.dart';
import 'package:bowsandties/Admin/Pages/CustomSidebarMenu.dart';
import 'package:bowsandties/Admin/Pages/Edit_Product.dart';
import 'package:bowsandties/Admin/Pages/View_Product.dart';
import 'package:bowsandties/Cart/Cart_Items.dart';
import 'package:bowsandties/Cart/Order_Summary.dart';
import 'package:bowsandties/Cart/Razor_Pay.dart';
import 'package:bowsandties/Cart/payment_Method.dart';
import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:bowsandties/Details_page/HomePage.dart';
import 'package:bowsandties/Feedback/Feedbackpage.dart';
import 'package:bowsandties/Landing/HomePage.dart';
import 'package:bowsandties/Landing/My_Orders.dart';
import 'package:bowsandties/Landing/Sub_Category.dart';
import 'package:bowsandties/Landing/Terms/privacy_policy_page.dart';
import 'package:bowsandties/Landing/Terms/refund_policy_page.dart';
import 'package:bowsandties/Landing/Terms/shipping_policy_page.dart';
import 'package:bowsandties/Landing/Terms/terms_conditions_page.dart';
import 'package:bowsandties/Login/Login.dart';
import 'package:bowsandties/Search/Pages/HomePage.dart';
import 'package:bowsandties/Services/share/Shared_details.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');

    final isAdmin = role == 'admin';

    final goingToAdmin = state.matchedLocation == '/DashBoard';
    if (goingToAdmin && !isAdmin) {
      return '/admin';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/DashBoard',
      name: 'DashBoard',
      builder: (context, state) => const CustomSidebarLayout(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminLoginPage(),
    ),
    GoRoute(
      path: '/Address',
      builder: (context, state) => const FetchAddressPage(),
    ),
    GoRoute(
      path: '/AddAddress',
      builder: (context, state) => const AddAddressPage(),
    ),
    GoRoute(path: '/Search', builder: (context, state) => const DetailsHome()),
    GoRoute(
      path: '/OrderSummary',
      builder: (context, state) => const OrderSummary(),
    ),
    GoRoute(
      path: '/razorpay/:amount',
      name: 'razorpay',
      builder: (context, state) {
        final amount =
            double.tryParse(state.pathParameters['amount'] ?? '0') ?? 0;
        return RazorPay(totalAmountToPay: amount);
      },
    ),

    GoRoute(path: '/Cart', builder: (context, state) => const ShowCart()),
    GoRoute(
      path: '/OrderConfirmation',
      builder: (context, state) => const OrderConfirmation(),
    ),

    GoRoute(path: '/', builder: (context, state) => const Home()),
    GoRoute(path: '/Home', builder: (context, state) => const Home()),
    GoRoute(
      path: '/Orders',
      builder: (context, state) => const OrdersTabScreen(),
    ),
    GoRoute(
      path: '/editproduct',
      builder: (context, state) {
        final product = state.extra as Product;
        return EditProductPage(product: product);
      },
    ),
    GoRoute(
      path: '/ProductDetailPage',
      builder: (context, state) {
        final product = state.extra as Product;
        return ProductDetailPage(product: product);
      },
    ),

    GoRoute(
      path: '/category/:name',
      builder: (context, state) {
        final category = state.pathParameters['name']!;
        return ProductsPage(category: category);
      },
    ),

    GoRoute(
      path: '/shippingpolicy',
      builder: (context, state) => const ShippingPolicyPage(),
    ),
    GoRoute(
      path: '/termsandconditions',
      builder: (context, state) => const TermsConditionsPage(),
    ),
    GoRoute(
      path: '/refund-policy',
      builder: (context, state) => const RefundPolicyPage(),
    ),
    GoRoute(
      path: '/privacypolicy',
      builder: (context, state) => const PrivacyPolicyPage(),
    ),

    GoRoute(
      path: '/ProductDetails',
      builder: (context, state) {
        final extra = state.extra;

        if (extra is Map<String, dynamic>) {
          final menuItem = SharedPreferencesCartItem.fromJson(extra);
          return HomePage(menuItem: menuItem);
        } else if (extra is SharedPreferencesCartItem) {
          return HomePage(menuItem: extra);
        }

        return const Scaffold(body: Center(child: Text("Invalid data passed")));
      },
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) {
        return const FeedbackPage();
      },
    ),

    GoRoute(
      path: '/:id',
      builder: (context, state) {
        final Id = state.pathParameters['id']!;
        return ProductDetailsPage(Id: Id);
      },
    ),
  ],
);
