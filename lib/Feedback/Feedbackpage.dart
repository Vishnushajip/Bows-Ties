import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Services/Scaffold_Messanger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackFormState {
  final bool isSubmitting;
  final String feedback;
  final Map<String, int> ratings;

  FeedbackFormState({
    this.isSubmitting = false,
    this.feedback = '',
    this.ratings = const {},
  });

  FeedbackFormState copyWith({
    bool? isSubmitting,
    String? feedback,
    Map<String, int>? ratings,
  }) {
    return FeedbackFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      feedback: feedback ?? this.feedback,
      ratings: ratings ?? this.ratings,
    );
  }
}

class FeedbackFormNotifier extends StateNotifier<FeedbackFormState> {
  final Ref ref;
  final String orderId;
  final List<dynamic> items;

  FeedbackFormNotifier(this.ref, this.orderId, this.items)
    : super(FeedbackFormState());

  void updateRating(String productId, int rating) {
    final updatedRatings = Map<String, int>.from(state.ratings)
      ..[productId] = rating;
    state = state.copyWith(ratings: updatedRatings);
  }

  void updateFeedback(String value) {
    state = state.copyWith(feedback: value);
  }

  Future<void> submit(BuildContext context) async {
    if (state.feedback.trim().isEmpty || state.ratings.isEmpty) {
      CustomMessenger(
        context: context,
        message: "Please fill in feedback and rate at least one item.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      ).show();
      return;
    }

    state = state.copyWith(isSubmitting: true);
    try {
      await FirebaseFirestore.instance.collection('feedback').doc(orderId).set({
        'orderId': orderId,
        'feedback': state.feedback.trim(),
        'ratings': state.ratings,
        'timestamp': DateTime.now().toIso8601String(),
      });

      for (final entry in state.ratings.entries) {
        final productName = entry.key; 
        final rating = entry.value.toDouble();

        final productQuery = await FirebaseFirestore.instance
            .collection('Products')
            .where('name', isEqualTo: productName)
            .limit(1)
            .get();

        if (productQuery.docs.isEmpty) {
          debugPrint('Product with name $productName not found');
          continue;
        }

        final productDoc = productQuery.docs.first;
        final data = productDoc.data();
        final existingAvg = (data['averageRating'] ?? 0).toDouble();
        final existingCount = (data['ratingCount'] ?? 0).toInt();

        final newAvg =
            ((existingAvg * existingCount) + rating) / (existingCount + 1);
        final newCount = existingCount + 1;

        await FirebaseFirestore.instance
            .collection('Products')
            .doc(productDoc.id)
            .update({'averageRating': newAvg, 'ratingCount': newCount});
      }

      CustomMessenger(
        context: context,
        message: "Feedback submitted successfully!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      ).show();

      state = FeedbackFormState();
      Future.delayed(const Duration(milliseconds: 300), () {
        context.go('/');
      });
    } catch (e) {
      CustomMessenger(
        context: context,
        message: "Failed to submit feedback: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      ).show();
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final feedbackFormProvider = StateNotifierProvider.family
    .autoDispose<
      FeedbackFormNotifier,
      FeedbackFormState,
      (String, List<dynamic>)
    >((ref, args) {
      final (orderId, items) = args;
      return FeedbackFormNotifier(ref, orderId, items);
    });

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.base;
    final orderId = uri.queryParameters['orderId'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Feedback', style: GoogleFonts.nunito(color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.accentColor,
      ),
      body: orderId.isEmpty
          ? const Center(child: Text('Invalid or missing order ID'))
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('orders')
                  .doc(orderId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Order not found'));
                }

                final orderData = snapshot.data!.data() as Map<String, dynamic>;
                final items = orderData['items'] as List<dynamic>;

                return FeedbackForm(orderId: orderId, items: items);
              },
            ),
    );
  }
}

class FeedbackForm extends ConsumerWidget {
  final String orderId;
  final List<dynamic> items;

  const FeedbackForm({super.key, required this.orderId, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(feedbackFormProvider((orderId, items)));
    final notifier = ref.read(feedbackFormProvider((orderId, items)).notifier);

    return Container(
      color: Colors.pink[50]!.withOpacity(0.2),
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            'We value your feedback!',
            style: GoogleFonts.pacifico(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: Colors.pink[700],
            ),
          ),
          Text(
            'Rate each item and share your shopping experience.',
            style: GoogleFonts.lora(fontSize: 16, color: Colors.pink[400]),
          ),
          const SizedBox(height: 20),

          ...items.map((item) {
            final name = item['name'] ?? 'Unknown';
            final price = item['price']?.toString() ?? '0.00';
            final imageUrl = (item['imageUrls'] as List?)?.first ?? '';
            final rating = form.ratings[name] ?? 3;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: Colors.pink[200]!.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl.isNotEmpty)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.error,
                                  color: Colors.redAccent,
                                ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      'Name: $name',
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.pink[600],
                      ),
                    ),
                    Text(
                      'Price: ₹$price',
                      style: GoogleFonts.lora(
                        fontSize: 14,
                        color: Colors.pink[400],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your Rating:',
                      style: GoogleFonts.lora(
                        fontSize: 14,
                        color: Colors.pink[400],
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return IconButton(
                          icon: Icon(
                            starIndex <= rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.pink[300],
                            size: 28,
                          ),
                          onPressed: () =>
                              notifier.updateRating(name, starIndex),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
          TextField(
            cursorColor: Colors.pink[700],
            onChanged: notifier.updateFeedback,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Write your feedback',
              labelStyle: GoogleFonts.lora(color: Colors.pink[400]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.pink[200]!, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.pink[100]!, width: 1),
              ),
            ),
            style: GoogleFonts.lora(color: Colors.pink[600]),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: form.isSubmitting
                  ? null
                  : () => notifier.submit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                shadowColor: Colors.pink[100]!.withOpacity(0.5),
              ),
              child: form.isSubmitting
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(
                      'Submit',
                      style: GoogleFonts.pacifico(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
