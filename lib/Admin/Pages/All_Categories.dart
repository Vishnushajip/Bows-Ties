import 'package:bowsandties/Admin/Providers/categoriesProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewCategoriesPage extends ConsumerWidget {
  const ViewCategoriesPage({super.key});

  Future<void> _deleteCategory(
    WidgetRef ref,
    String docId,
    String imageUrl,
    BuildContext context,
  ) async {
    ref.read(deletingDocsProvider.notifier).add(docId);

    try {
      await FirebaseFirestore.instance
          .collection('Categories')
          .doc(docId)
          .delete();

      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
    } finally {
      ref.read(deletingDocsProvider.notifier).remove(docId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final deletingDocs = ref.watch(deletingDocsProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Categories', style: GoogleFonts.nunito()),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (snapshot) {
          final docs = snapshot.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final category = doc['category'];
              final imageUrl = doc['imageUrl'];
              final docId = doc.id;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        imageUrl,
                        width: isMobile ? 60 : 100,
                        height: isMobile ? 60 : 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: isMobile ? 60 : 100,
                            height: isMobile ? 60 : 100,
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Text(
                        category,
                        style: GoogleFonts.nunito(
                          fontSize: isMobile ? 16 : 20,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 8),

                    deletingDocs.contains(docId)
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteCategory(ref, docId, imageUrl, context),
                          ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
