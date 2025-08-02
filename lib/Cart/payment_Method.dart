// ignore_for_file: unused_result

import 'package:bowsandties/Cart/PaymentHandler.dart';
import 'package:bowsandties/Cart/Summary_end.dart';
import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Components/Reusbale_Payment_Alert.dart';
import 'package:bowsandties/Services/Scaffold_Messanger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Feedback/Landing_Feedback_alert.dart';

final paymentMethodProvider = StateProvider<String?>((ref) => null);
final CODloadingProvider = StateProvider<bool>((ref) => false);

class OrderConfirmation extends ConsumerStatefulWidget {
  const OrderConfirmation({super.key});

  @override
  _OrderConfirmationState createState() => _OrderConfirmationState();
}

class _OrderConfirmationState extends ConsumerState<OrderConfirmation> {
  late double totalAmountToPay;

  @override
  @override
  void initState() {
    super.initState();
    _loadTotalAmountFromPrefs();
  }

  Future<void> _loadTotalAmountFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final amount = prefs.getDouble('totalAmountToPay') ?? 0.0;
    setState(() {
      totalAmountToPay = amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedPaymentMethod = ref.watch(paymentMethodProvider);
    final isLoading = ref.watch(CODloadingProvider);
    final isMobile = MediaQuery.of(context).size.width <= 800;

    return WillPopScope(
      onWillPop: () async {
        ref.read(CODloadingProvider.notifier).state = false;
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          title: Text(
            'Select Payment Method',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // _buildPaymentOption(
                      //   context,
                      //   ref,
                      //   Icons.currency_rupee_sharp,
                      //   'Cash on Delivery',
                      //   selectedPaymentMethod,
                      // ),
                      // const SizedBox(height: 10),
                      _buildPaymentOption(
                        context,
                        ref,
                        Icons.payment,
                        'Online Payment',
                        selectedPaymentMethod,
                      ),
                      const SizedBox(height: 16),
                      const OrderSummaryPage(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // _buildPaymentOption(
                            //   context,
                            //   ref,
                            //   Icons.currency_rupee_sharp,
                            //   'Cash on Delivery',
                            //   selectedPaymentMethod,
                            // ),
                            // const SizedBox(height: 10),
                            _buildPaymentOption(
                              context,
                              ref,
                              Icons.payment,
                              'Online Payment',
                              selectedPaymentMethod,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      const Expanded(flex: 3, child: OrderSummaryPage()),
                    ],
                  ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total Amount',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${totalAmountToPay.toStringAsFixed(0)}/-',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(18.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF273847),
                            strokeWidth: 4.0,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (selectedPaymentMethod == null) {
                                    CustomMessenger(
                                      context: context,
                                      duration: Durations.extralong2,
                                      message:
                                          "Please select a payment method.",
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    ).show();
                                    return;
                                  }
                                  ref.read(CODloadingProvider.notifier).state =
                                      true;

                                  ref.read(CODloadingProvider.notifier).state =
                                      true;
                                  final PaymentHandler paymentHandler =
                                      PaymentHandler();

                                  try {
                                    if (selectedPaymentMethod ==
                                        'Online Payment') {
                                      context.pushNamed(
                                        'razorpay',
                                        pathParameters: {
                                          'amount': totalAmountToPay.toString(),
                                        },
                                      );
                                    } else if (selectedPaymentMethod ==
                                        'Cash on Delivery') {
                                      await paymentHandler.saveOrderDetails(
                                        ref,
                                      );
                                      await paymentHandler.clearCart(ref);

                                      ref
                                              .read(CODloadingProvider.notifier)
                                              .state =
                                          false;
                                      ReusableCountdownDialog(
                                        context: context,
                                        ref: ref,
                                        message: "Order Placed Successfully",
                                        imagePath:
                                            "assets/Animation - 1731992471934.json",
                                        onRedirect: () {
                                          context.push('/Orders');
                                        },
                                        button: 'My Orders',
                                        color: Colors.green,
                                        buttonTextColor: Colors.white,
                                        buttonColor: Colors.green,
                                      ).show();
                                    }
                                    ref.refresh(feedbackBottomSheetProvider);
                                  } catch (e) {
                                    ref
                                            .read(CODloadingProvider.notifier)
                                            .state =
                                        false;
                                    CustomMessenger(
                                      message:
                                          "Error occurred: ${e.toString()}",
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      context: context,
                                      duration: Durations.extralong2,
                                    ).show;
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            minimumSize: const Size(50, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Make Payment',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String value,
    String? selectedPaymentMethod,
  ) {
    final bool isSelected = selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        ref.read(paymentMethodProvider.notifier).state = value;
        _savePaymentMethod(value);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : Colors.black.withOpacity(0.2),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Radio<String>(
              value: value,
              groupValue: selectedPaymentMethod,
              onChanged: (String? newValue) {
                ref.read(paymentMethodProvider.notifier).state = newValue;
                _savePaymentMethod(newValue!);
              },
              activeColor: AppColors.primaryColor,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primaryColor;
                }
                return AppColors.primaryColor.withOpacity(0.5);
              }),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.backgroundColor
                    : AppColors.textColor.withOpacity(0.6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.textColor
                          : AppColors.primaryColor.withOpacity(0.7),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePaymentMethod(String method) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPaymentMethod', method);
    print("Selected Payment Method: $method");
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;

  const ResponsiveContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black26),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: child,
    );
  }
}
