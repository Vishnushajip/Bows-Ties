import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';

final pageIndexProvider = StateProvider<int>((ref) => 0);

class ImageHeader extends ConsumerStatefulWidget {
  final SharedPreferencesCartItem menuItem;

  const ImageHeader({required this.menuItem, super.key});

  @override
  _ImageHeaderState createState() => _ImageHeaderState();
}

class _ImageHeaderState extends ConsumerState<ImageHeader> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        width: isMobile ? double.infinity : screenWidth * 0.6,
        height: isMobile ? screenWidth * 1 : screenWidth * 0.4,
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              loadingBuilder: (context, event) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.grey[300]),
              ),
              backgroundDecoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(
                    widget.menuItem.imageUrls[index],
                  ),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.covered,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                  disableGestures: true,

                  heroAttributes: PhotoViewHeroAttributes(tag: index),
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error, size: 50, color: Colors.red),
                  ),
                  filterQuality: FilterQuality.high,
                  tightMode: true,
                );
              },
              itemCount: widget.menuItem.imageUrls.length,
              pageController: pageController,
              onPageChanged: (index) {
                ref.read(pageIndexProvider.notifier).state = index;
              },
            ),
          ],
        ),
      ),
    );
  }
}
