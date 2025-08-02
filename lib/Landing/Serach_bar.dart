import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Landing/Providers/Search_Hint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchInput extends ConsumerWidget {
  const SearchInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hintIndex = ref.watch(searchHintProvider);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final searchController = TextEditingController();
    final hints = ref.read(searchHintProvider.notifier).hints;
    final isMobile = screenWidth <= 800;

    final padding = isMobile ? 16.0 : 24.0;
    final fontSize = isMobile ? 14.0 : 16.0;
    final iconSize = isMobile ? 20.0 : 24.0;
    final containerWidth = isMobile ? screenWidth * 0.9 : screenWidth * 0.5;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.backgroundColor,
            border: Border.all(color: AppColors.footercolor, width: 0.5),
            
          ),
          width: containerWidth,
          margin: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
          child: Stack(
            children: [
              TextField(
                readOnly: true,
                onTap: () {
                  context.push("/Search");
                },
                controller: searchController,
                style: GoogleFonts.nunito(
                  color: AppColors.primaryColor,
                  fontSize: fontSize,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primaryColor,
                    size: iconSize,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: animation.drive(
                            Tween<Offset>(
                              begin: const Offset(0, 0.5),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeInOut)),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 48, right: 20),
                      key: ValueKey<int>(hintIndex),
                      child: Row(
                        children: [
                          Text(
                            'Search ',
                            style: GoogleFonts.nunito(
                              fontSize: fontSize,
                              color: AppColors.primaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Expanded(
                            child: Text(
                              hints.isNotEmpty
                                  ? '"${hints[hintIndex]}"'
                                  : '"Pawsome Accessories"',
                              style: GoogleFonts.nunito(
                                fontSize: fontSize,
                                color: AppColors.primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
