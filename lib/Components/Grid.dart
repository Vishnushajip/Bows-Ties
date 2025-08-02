import 'package:bowsandties/Components/FirestoreCart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final hoverProvider = StateProvider.family<bool, String>((ref, id) => false);

class PropertyCard extends ConsumerWidget {
  final SharedPreferencesCartItem data;
  final VoidCallback? onTap;

  const PropertyCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width <= 800;
    final cardWidth = isMobile
        ? MediaQuery.of(context).size.width / 2 - 24
        : MediaQuery.of(context).size.width / 3 - 32;
    final imageUrl = (data.imageUrls.isNotEmpty) ? data.imageUrls[0] : '';
    final isHovered = ref.watch(hoverProvider(data.id));

    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => ref.read(hoverProvider(data.id).notifier).state = true,
      onTapUp: (_) => ref.read(hoverProvider(data.id).notifier).state = false,
      onTapCancel: () =>
          ref.read(hoverProvider(data.id).notifier).state = false,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.12),
                offset: Offset(0, 1),
                blurRadius: 3,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.24),
                offset: Offset(0, 1),
                blurRadius: 2,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    transform: Matrix4.identity()
                      ..translate(0.0, isHovered ? -25 : 0.0),
                    height: cardWidth * 0.7,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C3A6B),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isHovered
                          ? const [
                              BoxShadow(
                                color: Color.fromRGBO(226, 196, 63, 0.25),
                                offset: Offset(0, 13),
                                blurRadius: 47,
                                spreadRadius: -5,
                              ),
                              BoxShadow(
                                color: Color.fromRGBO(180, 71, 71, 0.3),
                                offset: Offset(0, 8),
                                blurRadius: 16,
                                spreadRadius: -8,
                              ),
                            ]
                          : [],
                      image: imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.fill,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    data.name,
                    style: GoogleFonts.nunito(
                      fontSize: 12,

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFDDDDDD))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.price.toString(),
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTapDown: (_) =>
                                ref
                                        .read(hoverProvider(data.id).notifier)
                                        .state =
                                    true,
                            onTapUp: (_) =>
                                ref
                                        .read(hoverProvider(data.id).notifier)
                                        .state =
                                    false,
                            onTapCancel: () =>
                                ref
                                        .read(hoverProvider(data.id).notifier)
                                        .state =
                                    false,
                            onTap: onTap,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.all(4.8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isHovered
                                      ? const Color(0xFF1C3A6B)
                                      : const Color(0xFF252525),
                                ),
                                borderRadius: BorderRadius.circular(50),
                                color: isHovered
                                    ? const Color(0xFF1C3A6B)
                                    : Colors.transparent,
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: Color(0xFF252525),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
