import 'package:bowsandties/Admin/Providers/productFormProvider.dart';
import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Services/Scaffold_Messanger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final isSavingProvider = StateProvider<bool>((ref) => false);

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final nameController = TextEditingController();
  final colorController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    colorController.dispose();
    descController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(productFormProvider);
    final formNotifier = ref.read(productFormProvider.notifier);
    final categories = ref.watch(categoriesProvider);
    final isSaving = ref.watch(isSavingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Add Product', style: GoogleFonts.nunito()),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  child: ListView(
                    children: [
                      _inputField(
                        label: 'Product Name',
                        controller: nameController,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _showProductNamePicker,
                        ),
                        onChanged: (val) =>
                            formNotifier.state = formState.copyWith(name: val),
                      ),
                      _inputField(
                        label: 'Color',
                        controller: colorController,
                        onChanged: (val) =>
                            formNotifier.state = formState.copyWith(color: val),
                      ),
                      const SizedBox(height: 16),
                      categories.when(
                        data: (catList) => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          value: formState.category.isEmpty
                              ? null
                              : formState.category,
                          items: catList
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              formNotifier.state = formState.copyWith(
                                category: val,
                              );
                            }
                          },
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      _inputField(
                        label: 'Description',
                        controller: descController,
                        maxLines: 4,
                        onChanged: (val) => formNotifier.state = formState
                            .copyWith(description: val),
                      ),
                      _inputField(
                        label: 'Price',
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (val) => formNotifier.state = formState
                            .copyWith(price: double.tryParse(val) ?? 0),
                      ),
                      _inputField(
                        label: 'Quantity',
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) => formNotifier.state = formState
                            .copyWith(quantity: int.tryParse(val) ?? 0),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('Pick Images (Min 1)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                        ),
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.image,
                            allowMultiple: true,
                            withData: true,
                          );

                          if (result != null && result.files.isNotEmpty) {
                            formNotifier.state = formState.copyWith(
                              images: result.files,
                            );
                          } else {
                            CustomMessenger(
                              textColor: AppColors.backgroundColor,
                              context: context,
                              message: "Please select at least 1 image",
                              backgroundColor: Colors.red,
                            ).show();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      formState.images.isNotEmpty
                          ? Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: formState.images.map((file) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    file.bytes!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            )
                          : const SizedBox.shrink(),

                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: formState.images.isNotEmpty
                            ? () => _saveProduct(context)
                            : null,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          'Save Product',
                          style: GoogleFonts.nunito(
                            color: AppColors.backgroundColor,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  strokeAlign: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _inputField({
    required String label,
    Widget? suffixIcon,
    required TextEditingController controller,
    required void Function(String) onChanged,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        style: const TextStyle(color: Colors.black),
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _saveProduct(BuildContext context) async {
    final form = ref.read(productFormProvider);
    final loading = ref.read(isSavingProvider.notifier);

    if (form.name.isEmpty ||
        form.color.isEmpty ||
        form.category.isEmpty ||
        form.description.isEmpty ||
        form.price <= 0 ||
        form.quantity <= 0) {
      CustomMessenger(
        context: context,
        message: "Please fill in all fields",
        duration: Durations.extralong1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      ).show();
      return;
    }

    try {
      loading.state = true;

      final storage = FirebaseStorage.instance;
      final imageUrls = <String>[];

      for (final image in form.images) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final ref = storage.ref().child('Products/$fileName');
        await ref.putData(
          image.bytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      final docRef = FirebaseFirestore.instance.collection('Products').doc();
      await docRef.set({
        'id': docRef.id,
        'name': form.name,
        'color': form.color,
        'category': form.category,
        'desc': form.description,
        'price': form.price,
        'quantity': form.quantity,
        'imageUrls': imageUrls,
        'timestamp': DateTime.now().toIso8601String(),
      });

      CustomMessenger(
        context: context,
        message: "Product saved successfully.",
        backgroundColor: Colors.green,
        textColor: Colors.white,
        duration: Durations.extralong1,
      ).show;

      nameController.clear();
      colorController.clear();
      descController.clear();
      priceController.clear();
      quantityController.clear();

      ref.read(productFormProvider.notifier).state = ProductFormState();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      loading.state = false;
    }
  }

  Future<void> _showProductNamePicker() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Products')
        .get();
    final names = snapshot.docs.map((doc) => doc['name'].toString()).toList();

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6, 
            maxChildSize: 0.95,
            minChildSize: 0.4,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Select Product Name',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: names.length,
                      itemBuilder: (context, index) {
                        final name = names[index];
                        return ListTile(
                          title: Text(name),
                          onTap: () {
                            nameController.text = name;
                            ref.read(productFormProvider.notifier).state = ref
                                .read(productFormProvider)
                                .copyWith(name: name);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }
}
