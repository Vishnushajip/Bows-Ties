import 'dart:js' as js;

import 'package:bowsandties/Cart/PaymentHandler.dart';
import 'package:bowsandties/Components/Reusbale_Payment_Alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RazorPay extends ConsumerStatefulWidget {
  final double totalAmountToPay;

  const RazorPay({super.key, required this.totalAmountToPay});

  @override
  ConsumerState<RazorPay> createState() => _RazorPayState();
}

class _RazorPayState extends ConsumerState<RazorPay> {
  @override
  void initState() {
    super.initState();
    openWebCheckout();
  }

  Future<void> openWebCheckout() async {
    final prefs = await SharedPreferences.getInstance();
    final addressList = prefs.getStringList('selected_address');
    final email = addressList != null ? addressList[0] : 'customer@example.com';
    final contact = addressList != null ? addressList[2] : '9876543210';
    final storedOrderId = prefs.getString('RazorpayorderId');
    final options = js.JsObject.jsify({
      'key': 'rzp_live_AGdllThU8VdTyw',
      'amount': (widget.totalAmountToPay * 100).toInt(),
      'currency': 'INR',
      'name': 'Bows & Ties India',
      'description': 'Bows And Ties Order',
      'image': 'https://bowsandties.in/splash.png',
      'prefill': {'contact': contact, 'email': email},
      if (storedOrderId != null) 'order_id': storedOrderId,
      'theme': {'color': '#273847'},
      'handler': js.allowInterop((response) async {
        await _onPaymentSuccess(response);
      }),
      'modal': {
        'ondismiss': js.allowInterop(() {
          _onPaymentCancelled();
        }),
      },
    });

    final razorpay = js.context.callMethod('Razorpay', [options]);
    razorpay.callMethod('open');
  }

  Future<void> _onPaymentSuccess(dynamic response) async {
    try {
      final paymentHandler = PaymentHandler();
      await paymentHandler.saveOrderDetails(ref);
      await paymentHandler.clearCart(ref);

      ReusableCountdownDialog(
        context: context,
        ref: ref,
        message: "Order Placed Successfully",
        imagePath: "imageurl",
        onRedirect: () {
          context.go('/Orders');
        },
        button: 'My Orders',
        color: Colors.green,
        buttonColor: Colors.green,
        buttonTextColor: Colors.white,
      ).show();
    } catch (e) {
      print("Payment success but failed to save order: $e");
    }
  }

  void _onPaymentCancelled() {
    ReusableCountdownDialog(
      context: context,
      ref: ref,
      message: "Payment Cancelled",
      imagePath: "imageurl",
      onRedirect: () {
        context.go('/');
      },
      button: 'Back to Home',
      color: Colors.red,
      buttonColor: Colors.red,
      buttonTextColor: Colors.white,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF273847)),
            SizedBox(height: 20),
            Text(
              'Redirecting to Razorpay...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF273847),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
