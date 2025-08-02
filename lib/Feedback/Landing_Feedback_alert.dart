import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Services/Guest_Alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackState {
  final int rating;
  final String comment;
  final bool isSubmitting;

  FeedbackState({
    this.rating = 3,
    this.comment = '',
    this.isSubmitting = false,
  });

  FeedbackState copyWith({int? rating, String? comment, bool? isSubmitting}) {
    return FeedbackState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class FeedbackNotifier extends StateNotifier<FeedbackState> {
  FeedbackNotifier() : super(FeedbackState());

  void updateRating(int rating) {
    state = state.copyWith(rating: rating);
  }

  void updateComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  Future<void> submit(BuildContext context) async {
    if (state.rating == 0) {
      _toast("Please provide a star rating!");
      return;
    }

    if (state.comment.trim().isEmpty) {
      _toast("Please enter a comment!");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    final name = prefs.getString('name') ?? 'Guest';
    final photoUrl = prefs.getString('photoUrl') ?? '';

    state = state.copyWith(isSubmitting: true);

    try {
      final ordersQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('email', isEqualTo: email)
          .where('status', isNotEqualTo: 'Order Delivered')
          .get();

      if (ordersQuery.docs.isNotEmpty) {
        await FirebaseFirestore.instance.collection('Review').add({
          'email': email,
          'name': name,
          'photoUrl': photoUrl,
          'rating': state.rating,
          'comment': state.comment,
          'timestamp': FieldValue.serverTimestamp(),
        });

        for (final doc in ordersQuery.docs) {
          await doc.reference.update({'reviewStatus': 'review added'});
        }

        state = state.copyWith(isSubmitting: false);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.pink[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Thank You!',
              style: GoogleFonts.pacifico(
                fontSize: 24,
                color: Colors.pink[700],
              ),
            ),
            content: Text(
              'Thank you for your review!',
              style: GoogleFonts.lora(fontSize: 16, color: Colors.pink[400]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: Colors.pink[700],
                  ),
                ),
              ),
            ],
          ),
        ).then((_) => Navigator.of(context).pop());
      } else {
        _toast("No eligible orders found for feedback.");
        state = state.copyWith(isSubmitting: false);
      }
    } catch (e) {
      _toast("Something went wrong. Please try again.$e");
      state = state.copyWith(isSubmitting: false);
    }
  }

  void _toast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.pink[700],
      textColor: Colors.white,
    );
  }
}

final feedbackBottomSheetProvider =
    StateNotifierProvider<FeedbackNotifier, FeedbackState>(
      (ref) => FeedbackNotifier(),
    );

class FeedbackBottomSheet extends ConsumerWidget {
  const FeedbackBottomSheet({super.key});

  static Future<void> checkAndShowIfEligible(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    if (email.isEmpty) {
      LoginBottomSheet.checkAndShow(context);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('email', isEqualTo: email)
          .get();

      final eligibleOrders = snapshot.docs.where((doc) {
        final status = doc['status'] ?? '';
        final reviewStatus = doc.data().containsKey('reviewStatus')
            ? doc['reviewStatus']
            : null;

        final isNotDelivered = status != 'Order Delivered';
        final notReviewed =
            reviewStatus == null || reviewStatus != 'review added';

        return isNotDelivered && notReviewed;
      });

      if (eligibleOrders.isNotEmpty) {
        show(context);
      }
    } catch (e) {
      print("Error checking feedback eligibility: $e");
    }
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      isDismissible: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FeedbackBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedbackBottomSheetProvider);
    final notifier = ref.read(feedbackBottomSheetProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.borderColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.pink[100]!.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: state.isSubmitting
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      'We’d Love Your Feedback!',
                      style: GoogleFonts.pacifico(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tell us about your shopping experience.',
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        color: AppColors.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your Rating:',
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          icon: Icon(
                            star <= state.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.primaryColor,
                            size: 30,
                          ),
                          onPressed: () => notifier.updateRating(star),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      cursorColor: AppColors.primaryColor,
                      onChanged: notifier.updateComment,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Your Feedback',
                        labelStyle: GoogleFonts.lora(color: Colors.pink[400]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.pink[100]!,
                            width: 1,
                          ),
                        ),
                      ),
                      style: GoogleFonts.lora(color: AppColors.primaryColor),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () => notifier.submit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          'Submit',
                          style: GoogleFonts.pacifico(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
