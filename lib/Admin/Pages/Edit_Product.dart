import 'dart:typed_data';

import 'package:bowsandties/Admin/Pages/All_Products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController nameController;
  late TextEditingController colorController;
  late TextEditingController categoryController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  List<Uint8List> newImages = [];
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    nameController = TextEditingController(text: p.name);
    colorController = TextEditingController(text: p.color);
    categoryController = TextEditingController(text: p.category);
    descController = TextEditingController(text: p.desc);
    priceController = TextEditingController(text: p.price.toString());
    quantityController = TextEditingController(text: p.quantity.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    colorController.dispose();
    categoryController.dispose();
    descController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> pickNewImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.image,
    );
    if (result != null) {
      setState(() => newImages = result.files.map((e) => e.bytes!).toList());
    }
  }

  Future<void> saveChanges() async {
    setState(() => isSaving = true);

    final id = widget.product.id;
    final docRef = FirebaseFirestore.instance.collection('Products').doc(id);

    List<String> imageUrls = widget.product.imageUrls;

    if (newImages.isNotEmpty) {
      for (final url in imageUrls) {
        try {
          await FirebaseStorage.instance.refFromURL(url).delete();
        } catch (_) {}
      }
      imageUrls.clear();

      for (int i = 0; i < newImages.length; i++) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final ref = FirebaseStorage.instance.ref().child('Products/$fileName');
        await ref.putData(
          newImages[i],
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
    }

    await docRef.update({
      'name': nameController.text.trim(),
      'color': colorController.text.trim(),
      'category': categoryController.text.trim(),
      'desc': descController.text.trim(),
      'price': double.tryParse(priceController.text.trim()) ?? 0,
      'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
      'imageUrls': imageUrls,
    });

    setState(() => isSaving = false);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Product",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isSaving
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildField("Product Name", nameController),
                  buildField("Color", colorController),
                  buildField("Category", categoryController),
                  buildField("Description", descController, maxLines: 3),
                  buildField(
                    "Price",
                    priceController,
                    keyboardType: TextInputType.number,
                  ),
                  buildField(
                    "Quantity",
                    quantityController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: pickNewImages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                    ),
                    child: const Text(
                      "Pick New Images",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (newImages.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      children: newImages
                          .map(
                            (img) => Image.memory(
                              img,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                          .toList(),
                    )
                  else if (widget.product.imageUrls.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      children: widget.product.imageUrls
                          .map(
                            (url) => Image.network(
                              url,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(
                      "Save Changes",
                      style: GoogleFonts.nunito(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: saveChanges,
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.nunito(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
