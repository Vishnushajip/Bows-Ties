import 'dart:async';

import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Landing/Providers/Carousel.dart';
import 'package:bowsandties/Landing/Providers/CarouselIndex.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CarouselSliderWidget extends ConsumerStatefulWidget {
  const CarouselSliderWidget({super.key});

  @override
  _CarouselSliderWidgetState createState() => _CarouselSliderWidgetState();
}

class _CarouselSliderWidgetState extends ConsumerState<CarouselSliderWidget> {
  late final PageController _pageController;
  Timer? _timer;
  bool _isAutoScrollInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carouselData = ref.watch(carouselProvider);
    final isMobile = MediaQuery.of(context).size.width <= 800;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        final double carouselHeight = isDesktop
            ? MediaQuery.of(context).size.height * 0.2
            : MediaQuery.of(context).size.height * 0.25;

        final double carouselWidth = isDesktop
            ? MediaQuery.of(context).size.width * 0.4
            : MediaQuery.of(context).size.width * 0.9;

        return carouselData.when(
          data: (items) {
            if (items.isEmpty) {
              return const SizedBox.shrink();
            }

            _startAutoScroll(items.length);

            return Container(
              height: carouselHeight,
              width: carouselWidth,
              decoration: BoxDecoration(
                color: AppColors.footercolor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.footercolor, width: 1),
              ),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: items.length,
                    onPageChanged: (index) {
                      ref
                          .read(carouselIndexProvider.notifier)
                          .setIndex(index);
                    },
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        onTap: () =>
                            context.push('/ProductDetails', extra: item),
                        onPanDown: (details) => _timer?.cancel(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: GoogleFonts.pacifico(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.primaryColor,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Best ${item.name} collections for you',
                                            style: GoogleFonts.lora(
                                              fontSize: 12,
                                              color: AppColors.primaryColor,
                                              height: 1.4,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: CachedNetworkImage(
                                      imageUrl: item.imageUrls[0],
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                            baseColor:
                                                AppColors.footercolor,
                                            highlightColor:
                                                Colors.grey[50]!,
                                            child: Container(
                                              height: carouselHeight,
                                              color: Colors.white,
                                            ),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                            Icons.error,
                                            color: Colors.redAccent,
                                          ),
                                      fit: BoxFit.cover,
                                      height: carouselHeight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: items.length,
                        effect: const ScaleEffect(
                          dotHeight: 6,
                          dotWidth: 10,
                          activeDotColor: AppColors.primaryColor,
                          dotColor: AppColors.borderColor,
                          spacing: 8.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => Shimmer.fromColors(
            baseColor: AppColors.footercolor,
            highlightColor: AppColors.borderColor,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: isMobile
                      ? MediaQuery.of(context).size.width * 0.9
                      : MediaQuery.of(context).size.width * 0.4,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
    );
  }

  void _startAutoScroll(int itemCount) {
    if (_isAutoScrollInitialized) return;
    _isAutoScrollInitialized = true;

    int currentIndex = 0;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_pageController.hasClients) {
        timer.cancel();
        return;
      }

      final nextIndex = (currentIndex + 1) % itemCount;

      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      currentIndex = nextIndex;
      ref.read(carouselIndexProvider.notifier).setIndex(nextIndex);
    });
  }
}
