import 'package:bowsandties/Components/App_Colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

final reviewsStreamProvider =
    StateNotifierProvider<
      ReviewsNotifier,
      AsyncValue<List<Map<String, dynamic>>>
    >((ref) {
      return ReviewsNotifier();
    });

class ReviewsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  ReviewsNotifier() : super(const AsyncValue.loading()) {
    _fetchInitialReviews();
  }

  final int _pageSize = 5;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  Future<void> _fetchInitialReviews() async {
    try {
      state = const AsyncValue.loading();
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Review')
          .orderBy('timestamp', descending: true)
          .limit(_pageSize)
          .get();
      final reviews = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'name': data['name'] as String? ?? 'Anonymous',
              'photoUrl': data['photoUrl'] as String? ?? '',
              'rating': (data['rating'] as num?)?.toInt() ?? 0,
              'comment': data['comment'] as String? ?? '',
              'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
            };
          })
          .where((review) => review['name'] != 'Guest')
          .toList();
      _lastDocument = querySnapshot.docs.isNotEmpty
          ? querySnapshot.docs.last
          : null;
      _hasMore = querySnapshot.docs.length == _pageSize;
      state = AsyncValue.data(reviews);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> fetchMoreReviews() async {
    if (!_hasMore || state.isLoading) return;
    try {
      state = AsyncValue.data([...?state.value]);
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Review')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();
      final newReviews = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] as String? ?? 'Anonymous',
          'photoUrl': data['photoUrl'] as String? ?? '',
          'rating': (data['rating'] as num?)?.toInt() ?? 0,
          'comment': data['comment'] as String? ?? '',
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
        };
      }).toList();
      _lastDocument = querySnapshot.docs.isNotEmpty
          ? querySnapshot.docs.last
          : null;
      _hasMore = querySnapshot.docs.length == _pageSize;
      state = AsyncValue.data([...?state.value, ...newReviews]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class FeedbackView extends ConsumerStatefulWidget {
  const FeedbackView({super.key});

  @override
  ConsumerState<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends ConsumerState<FeedbackView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9) {
        ref.read(reviewsStreamProvider.notifier).fetchMoreReviews();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 800;
    final reviewsAsync = ref.watch(reviewsStreamProvider);

    final padding = isMobile ? 5.0 : 24.0;
    final bodyFontSize = isMobile ? 14.0 : 16.0;
    final smallFontSize = isMobile ? 12.0 : 14.0;
    final imageSize = isMobile ? 50.0 : 60.0;
    final starSize = isMobile ? 20.0 : 24.0;
    final cardWidth = isMobile ? 300.0 : 400.0;
    final cardMinHeight = isMobile ? 150.0 : 180.0;
    final cardMaxHeight = isMobile ? 200.0 : 240.0;

    return Container(
      color: AppColors.backgroundColor,
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Customer Reviews⭐',
            style: GoogleFonts.mochiyPopOne(
              fontWeight: FontWeight.w400,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          reviewsAsync.when(
            data: (reviews) {
              if (reviews.isEmpty) {
                return const SizedBox.shrink();
              }
              return isMobile
                  ? SizedBox(
                      height: cardMaxHeight + 20,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        itemCount: reviews.length,
                        itemBuilder: (context, index) => _buildReviewCard(
                          context,
                          reviews[index],
                          cardWidth,
                          cardMinHeight,
                          cardMaxHeight,
                          imageSize,
                          starSize,
                          bodyFontSize,
                          smallFontSize,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: (cardMaxHeight * 2) + 36,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.2,
                            ),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) => _buildReviewCard(
                          context,
                          reviews[index],
                          cardWidth,
                          cardMinHeight,
                          cardMaxHeight,
                          imageSize,
                          starSize,
                          bodyFontSize,
                          smallFontSize,
                        ),
                      ),
                    );
            },
            loading: () => _buildLoadingShimmer(
              isMobile,
              cardWidth,
              cardMinHeight,
              cardMaxHeight,
              padding,
            ),
            error: (error, stack) => Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: Text(
                'Oops! Something went wrong. Please try again later.',
                style: GoogleFonts.lora(
                  fontSize: bodyFontSize,
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    Map<String, dynamic> review,
    double cardWidth,
    double cardMinHeight,
    double cardMaxHeight,
    double imageSize,
    double starSize,
    double bodyFontSize,
    double smallFontSize,
  ) {
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: AppColors.borderColor, width: 1),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: cardMinHeight,
            maxHeight: cardMaxHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(imageSize / 2),
                      child: CachedNetworkImage(
                        imageUrl: review['photoUrl']!,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.primaryColor,
                          highlightColor: Colors.pink[50]!,
                          child: Container(
                            width: imageSize,
                            height: imageSize,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: imageSize,
                          height: imageSize,
                          color: Colors.pink[100]!.withOpacity(0.2),
                          child: Icon(
                            Icons.pets,
                            color: Colors.pink[400],
                            size: imageSize * 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['name']!,
                            style: GoogleFonts.nunito(
                              fontSize: bodyFontSize,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review['rating']!
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: starSize,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  review['comment']!,
                  style: GoogleFonts.lora(
                    fontSize: bodyFontSize - 2,
                    color: AppColors.textColor,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (review['comment']!.length > 50)
                  GestureDetector(
                    onTap: () {
                      _showReviewDialog(
                        context,
                        review,
                        bodyFontSize,
                        smallFontSize,
                        imageSize,
                        starSize,
                      );
                    },
                    child: Text(
                      'Read More',
                      style: GoogleFonts.lora(
                        fontSize: smallFontSize - 2,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        review['timestamp'] != null
                            ? DateFormat(
                                'MMMM d, yyyy, h:mm a',
                              ).format(review['timestamp']!)
                            : 'Unknown date',
                        style: GoogleFonts.lora(
                          fontSize: smallFontSize - 2,
                          color: AppColors.primaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReviewDialog(
    BuildContext context,
    Map<String, dynamic> review,
    double bodyFontSize,
    double smallFontSize,
    double imageSize,
    double starSize,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width:
              MediaQuery.of(context).size.width *
              (MediaQuery.of(context).size.width <= 800 ? 0.9 : 0.5),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.pink[50]!.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.primaryColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Customer Review',
                    style: GoogleFonts.pacifico(color: AppColors.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(imageSize / 2),
                    child: CachedNetworkImage(
                      imageUrl: review['photoUrl']!,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.primaryColor,
                        highlightColor: Colors.pink[50]!,
                        child: Container(
                          width: imageSize,
                          height: imageSize,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: imageSize,
                        height: imageSize,
                        color: Colors.pink[100]!.withOpacity(0.2),
                        child: Icon(
                          Icons.pets,
                          color: Colors.pink[400],
                          size: imageSize * 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['name']!,
                          style: GoogleFonts.lora(
                            fontSize: bodyFontSize,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Rating: ${review['rating']}',
                          style: GoogleFonts.lora(
                            fontSize: smallFontSize,
                            color: AppColors.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review['rating']! ? Icons.star : Icons.star_border,
                    color: AppColors.primaryColor,
                    size: starSize,
                  );
                }),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                child: Text(
                  review['comment']!,
                  style: GoogleFonts.lora(
                    fontSize: bodyFontSize - 2,
                    color: AppColors.primaryColor,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      review['timestamp'] != null
                          ? DateFormat(
                              'MMMM d, yyyy, h:mm a',
                            ).format(review['timestamp']!)
                          : 'Unknown date',
                      style: GoogleFonts.lora(
                        fontSize: smallFontSize - 2,
                        color: AppColors.primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.lora(
                      fontSize: smallFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer(
    bool isMobile,
    double cardWidth,
    double cardMinHeight,
    double cardMaxHeight,
    double padding,
  ) {
    return SizedBox(
      height: isMobile ? cardMaxHeight + 20 : (cardMaxHeight * 2) + 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          width: cardWidth,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Shimmer.fromColors(
              baseColor: AppColors.primaryColor,
              highlightColor: Colors.pink[50]!,
              child: Container(height: cardMinHeight, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
