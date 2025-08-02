// ignore_for_file: unused_result

import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Services/averageRatingProvider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import 'Providers/Watch&Shop.dart';

class WatchAndShop extends ConsumerWidget {
  const WatchAndShop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(productsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        final cardWidth = isDesktop ? 220.0 : 160.0;
        final imageHeight = cardWidth * 1.2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 40, height: 2, color: AppColors.footercolor),
                const SizedBox(width: 12),
                Text(
                  'New Arrivals',
                  style: GoogleFonts.mochiyPopPOne(
                    color: AppColors.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Container(width: 40, height: 2, color: AppColors.footercolor),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: imageHeight + 80,
              child: asyncData.when(
                data: (products) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        ref.read(productsProvider.notifier).refresh();
                        context.push('/ProductDetails', extra: product);
                      },
                      child: Container(
                        width: cardWidth,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              elevation: 6,
                              shadowColor: AppColors.borderColor.withOpacity(
                                0.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrls[0],
                                  width: cardWidth,
                                  height: imageHeight,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          width: cardWidth,
                                          height: imageHeight,
                                          color: AppColors.backgroundColor,
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: cardWidth,
                                        height: imageHeight,
                                        color: AppColors.footercolor,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 50,
                                          color: AppColors.footercolor,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                product.name,
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                "₹${product.price.toStringAsFixed(2)}/-",
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Consumer(
                              builder: (context, ref, _) {
                                final ratingAsync = ref.watch(
                                  averageRatingProvider(product.id),
                                );
                                return ratingAsync.when(
                                  data: (rating) {
                                    if (rating == 0.0) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Row(
                                        children: List.generate(5, (index) {
                                          return Icon(
                                            index < rating.round()
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 14,
                                          );
                                        }),
                                      ),
                                    );
                                  },
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                loading: () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Container(
                      width: cardWidth,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: cardWidth,
                              height: imageHeight,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: cardWidth * 0.7,
                              height: 14,
                              color: AppColors.backgroundColor,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: cardWidth * 0.4,
                              height: 12,
                              color: AppColors.backgroundColor,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(
                                5,
                                (index) => const Icon(
                                  Icons.star_border,
                                  size: 14,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}
