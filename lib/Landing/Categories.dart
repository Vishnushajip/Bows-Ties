import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Landing/Providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  static const Color lassoBrown = Color(0xFF9B6A57);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 800;
    final crossAxisCount = isMobile ? 2 : (screenWidth ~/ 180);
    final itemWidth =
        (screenWidth - 32 - ((crossAxisCount - 1) * 4)) / crossAxisCount;

    return categoriesAsync.when(
      data: (categories) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 30, height: 1.5, color: AppColors.footercolor),
              const SizedBox(width: 10),
              Text(
                'Categories',
                style: GoogleFonts.mochiyPopPOne(
                  color: AppColors.textColor,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 30, height: 1.5, color: AppColors.footercolor),
            ],
          ),

          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories.map((category) {
              return GestureDetector(
                onTap: () => context.push('/category/${category.name}'),
                child: Container(
                  width: itemWidth,
                  height: isMobile ? 150 : 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: lassoBrown.withOpacity(0.2)),
                    color: lassoBrown.withOpacity(0.05),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: category.imageUrl != null
                              ? Image.network(
                                  category.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            child: Text(
                              category.name,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 13 : 16,
                                shadows: const [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black45,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),

      loading: () => Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'Categories',
            style: GoogleFonts.nunito(fontSize: 24, color: lassoBrown),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(isMobile ? crossAxisCount : 4, (index) {
              return Shimmer.fromColors(
                baseColor: AppColors.footercolor,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: itemWidth,
                  height: isMobile ? 100 : 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
        ],
      ),

      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
