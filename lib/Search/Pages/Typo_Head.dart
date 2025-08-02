// ignore_for_file: unused_result

import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:bowsandties/Search/Providers/Search_suggetions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

final searchTextProvider = StateProvider<String>((ref) => '');

class SearchBarall extends ConsumerStatefulWidget {
  const SearchBarall({super.key});

  @override
  ConsumerState<SearchBarall> createState() => _SearchBarallState();
}

class _SearchBarallState extends ConsumerState<SearchBarall> {
  bool _hasSavedSearch = false;
  String _lastSearched = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Center(
      child: TypeAheadField<SharedPreferencesCartItem>(
        hideOnError: true,
        animationDuration: const Duration(milliseconds: 300),
        loadingBuilder: (context) {
          return buildLoadingListTile(isMobile);
        },
        hideKeyboardOnDrag: true,
        autoFlipDirection: true,
        suggestionsCallback: (pattern) async {
          if (pattern.trim().isEmpty) return [];

          try {
            final result = await ref.read(
              searchPropertyProvider(pattern).future,
            );

            if (result.isEmpty && pattern.trim().isNotEmpty) {
              if (!_hasSavedSearch || _lastSearched != pattern) {
                _hasSavedSearch = true;
                _lastSearched = pattern;
              }
            } else {
              _hasSavedSearch = false;
            }

            return result;
          } catch (e) {
            return [];
          }
        },
        itemBuilder: (context, suggestion) {
          final title = suggestion.name;
          final category = suggestion.category;
          final imageUrl = suggestion.imageUrls.isNotEmpty
              ? suggestion.imageUrls[0]
              : '';

          return ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: imageUrl.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: isMobile ? 60 : 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.fill,
                          imageUrl: imageUrl,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                : const Icon(Icons.image, size: 50),
            title: Text(title, style: GoogleFonts.nunito(fontSize: 15)),
            subtitle: Text(category, style: GoogleFonts.nunito(fontSize: 12)),
          );
        },
        onSelected: (suggestion) {
          context.push('/ProductDetails', extra: suggestion);
        },
        emptyBuilder: (context) {
          final pattern = ref.read(searchTextProvider);
          if (pattern.isEmpty) {
            return const SizedBox.shrink();
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://static.vecteezy.com/system/resources/previews/048/421/325/non_2x/concept-of-no-items-found-no-results-found-user-request-page-not-found-error-notification-404-web-and-mobile-application-symbols-illustration-in-the-background-vector.jpg',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 60,
                          height: 60,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No properties found for "$pattern"',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
        decorationBuilder: (context, child) {
          return Material(
            type: MaterialType.card,
            elevation: 4,
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: child,
          );
        },
        offset: const Offset(0, 12),
        constraints: BoxConstraints(
          maxHeight: 1000,
          maxWidth: screenHeight * 0.8,
        ),
        builder: (context, controller, focusNode) {
          controller.addListener(() {
            ref.read(searchTextProvider.notifier).state = controller.text;
          });
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              width: screenHeight * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
              ),
              child: TextField(
                autofocus: true,
                cursorColor: Colors.black,
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 12.0,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: 'Search by Location or Property ID',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: isMobile ? 9 : 14,
                    color: Colors.grey,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey, size: 25),
                    onPressed: () {
                      controller.clear();
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget buildLoadingListTile(bool isMobile) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    child: ListTile(
      contentPadding: const EdgeInsets.all(8),
      leading: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: isMobile ? 60 : 120,
          height: isMobile ? 60 : 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      title: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 16,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
        ),
      ),
      subtitle: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(height: 14, width: 100, color: Colors.white),
      ),
    ),
  );
}
