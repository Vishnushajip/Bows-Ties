// ignore_for_file: unused_result

import 'package:bowsandties/Address/Pages/All_Address.dart';
import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Services/Scaffold_Messanger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final addressFormProvider = StateProvider<AddressFormState>(
  (ref) => AddressFormState(),
);

class AddressFormState {
  final String type;

  AddressFormState({this.type = 'Home'});
}

final saveAddressProvider = Provider((ref) => SaveAddressService());

class SaveAddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveAddress({
    required String name,
    required String address,
    required String phoneNumber,
    required String pincode,
    required String type,
    required String email,
  }) async {
    try {
      await _firestore.collection('Address').add({
        'Name': name,
        'Address': address,
        'PhoneNumber': phoneNumber,
        'Pincode': pincode,
        'Type': type,
        'email': email,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save address: $e');
    }
  }
}

class AddAddressPage extends ConsumerStatefulWidget {
  const AddAddressPage({super.key});

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends ConsumerState<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    final addressFormState = ref.watch(addressFormProvider);
    final saveAddressService = ref.read(saveAddressProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Add Address',
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Address Type',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF273847),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildRadioButton(
                    title: 'Home',
                    value: 'Home',
                    groupValue: addressFormState.type,
                    isMobile: isMobile,
                    onChanged: (value) {
                      ref
                          .read(addressFormProvider.notifier)
                          .update((state) => AddressFormState(type: value!));
                    },
                  ),
                  _buildRadioButton(
                    title: 'Office',
                    value: 'Office',
                    groupValue: addressFormState.type,
                    isMobile: isMobile,
                    onChanged: (value) {
                      ref
                          .read(addressFormProvider.notifier)
                          .update((state) => AddressFormState(type: value!));
                    },
                  ),
                  _buildRadioButton(
                    title: 'Other',
                    value: 'Other',
                    groupValue: addressFormState.type,
                    isMobile: isMobile,
                    onChanged: (value) {
                      ref
                          .read(addressFormProvider.notifier)
                          .update((state) => AddressFormState(type: value!));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                isMobile: isMobile,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                isMobile: isMobile,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneNumberController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
                isMobile: isMobile,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _pincodeController,
                label: 'Pincode',
                icon: Icons.pin_drop,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a pincode';
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                    return 'Please enter a valid 6-digit pincode';
                  }
                  return null;
                },
                isMobile: isMobile,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    ref.refresh(addressesProvider);

                    if (_formKey.currentState!.validate()) {
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        final email = prefs.getString("email");
                        if (email == null || email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        await saveAddressService.saveAddress(
                          name: _nameController.text,
                          address: _addressController.text,
                          phoneNumber: _phoneNumberController.text,
                          pincode: _pincodeController.text,
                          type: addressFormState.type,
                          email: email,
                        );

                        CustomMessenger(
                          context: context,
                          duration: Durations.extralong2,
                          textColor: Colors.white,
                          backgroundColor: AppColors.primaryColor,
                          message: "Address saved successfully!",
                        ).show();
                        _formKey.currentState!.reset();
                        _nameController.clear();
                        _addressController.clear();
                        _phoneNumberController.clear();
                        _pincodeController.clear();
                        ref
                            .read(addressFormProvider.notifier)
                            .update((state) => AddressFormState());
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error: $e',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 12.0 : 16.0,
                      horizontal: isMobile ? 24.0 : 32.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Save Address',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required bool isMobile,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[600],
          fontSize: isMobile ? 12 : 14,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF273847),
          size: isMobile ? 20 : 24,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: isMobile ? 12.0 : 16.0,
          horizontal: 16.0,
        ),
      ),
      style: GoogleFonts.poppins(
        fontSize: isMobile ? 12 : 14,
        color: const Color(0xFF273847),
      ),
    );
  }

  Widget _buildRadioButton({
    required String title,
    required String value,
    required String groupValue,
    required bool isMobile,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 12 : 14,
            color: const Color(0xFF273847),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
