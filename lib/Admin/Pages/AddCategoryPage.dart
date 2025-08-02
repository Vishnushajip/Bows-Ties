import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Services/Scaffold_Messanger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final categoryFormProvider = StateProvider<CategoryFormState>(
  (ref) => CategoryFormState(),
);

final isSavingCategoryProvider = StateProvider<bool>((ref) => false);

class CategoryFormState {
  final String category;
  final PlatformFile? image;

  CategoryFormState({this.category = '', this.image});

  CategoryFormState copyWith({String? category, PlatformFile? image}) {
    return CategoryFormState(
      category: category ?? this.category,
      image: image ?? this.image,
    );
  }
}

class AddCategoryPage extends ConsumerWidget {
  const AddCategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(categoryFormProvider);
    final formNotifier = ref.read(categoryFormProvider.notifier);
    final isSaving = ref.watch(isSavingCategoryProvider);

    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Add Category', style: GoogleFonts.nunito()),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isMobile ? 400 : 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                      ),
                      onChanged: (value) {
                        formNotifier.state = formState.copyWith(
                          category: value,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            withData: true,
                          );

                          if (result != null && result.files.isNotEmpty) {
                            final file = result.files.first;

                            formNotifier.state = formState.copyWith(
                              image: file,
                            );
                          } else {
                            CustomMessenger(
                              context: context,
                              message: "Please select an image",
                              textColor: Colors.white,
                              backgroundColor: Colors.red,
                            ).show();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: Text(
                          'Pick Image',
                          style: GoogleFonts.nunito(
                            color: AppColors.borderColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (formState.image != null &&
                        formState.image!.bytes != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.memory(
                          formState.image!.bytes!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                        onPressed:
                            formState.category.isNotEmpty &&
                                formState.image != null
                            ? () => _saveCategory(context, ref)
                            : null,
                        child: Text(
                          'Save Category',
                          style: GoogleFonts.nunito(
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isSaving)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveCategory(BuildContext context, WidgetRef ref) async {
    final formState = ref.read(categoryFormProvider);
    final loading = ref.read(isSavingCategoryProvider.notifier);

    if (formState.category.isEmpty || formState.image == null) {
      CustomMessenger(
        context: context,
        message: "Please fill all fields and select an image",
        backgroundColor: Colors.red,
        duration: Durations.extralong1,
        textColor: Colors.white,
      ).show();
      return;
    }

    try {
      loading.state = true;

      final storage = FirebaseStorage.instance;
      final storageRef = storage.ref().child(
        'categories/${DateTime.now().millisecondsSinceEpoch}_${formState.image!.name}',
      );
      await storageRef.putData(
        formState.image!.bytes!,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('Categories').add({
        'category': formState.category,
        'imageUrl': imageUrl,
        'timestamp': DateTime.now().toIso8601String(),
      });

      CustomMessenger(
        context: context,
        message: "Category saved successfully",
        backgroundColor: Colors.green,
        duration: Durations.extralong1,
        textColor: Colors.white,
      ).show();

      ref.read(categoryFormProvider.notifier).state = CategoryFormState();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving category: $e')));
    } finally {
      loading.state = false;
    }
  }
}
