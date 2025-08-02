import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Services/Scaffold_Messanger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Address {
  final String name;
  final String address;
  final String phoneNumber;
  final String pincode;
  final String type;
  final String email;

  Address({
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.pincode,
    required this.type,
    required this.email,
  });

  factory Address.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Address(
      name: data['Name'] ?? '',
      address: data['Address'] ?? '',
      phoneNumber: data['PhoneNumber'] ?? '',
      pincode: data['Pincode'] ?? '',
      type: data['Type'] ?? '',
      email: data['email'] ?? '',
    );
  }
}

final addressesProvider = FutureProvider<List<Address>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email') ?? '';
  if (email.isEmpty) {
    return [];
  }
  final querySnapshot = await FirebaseFirestore.instance
      .collection('Address')
      .where('email', isEqualTo: email)
      .get();
  return querySnapshot.docs.map((doc) => Address.fromFirestore(doc)).toList();
});

class FetchAddressPage extends ConsumerWidget {
  const FetchAddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Address',
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
       
      ),
      body: addressesAsync.when(
        data: (addresses) => addresses.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.push('/AddAddress');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.add, color: Color(0xFF273847)),
                            const SizedBox(width: 12.0),
                            Text(
                              'Add address',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF273847),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Icon(
                    Icons.location_off,
                    size: isMobile ? 60 : 80,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No addresses found',
                    style: GoogleFonts.nunito(
                      fontSize: isMobile ? 16 : 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 10.0 : 16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.push('/AddAddress');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.add, color: Color(0xFF273847)),
                              const SizedBox(width: 12.0),
                              Text(
                                'Add address',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF273847),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return GestureDetector(
                          onTap: () {
                            _saveAddressToPrefs(address, context);
                            Navigator.pop(context);
                          },
                          child: _buildAddressCard(
                            address,
                            isMobile,
                            screenWidth,
                            context,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
            strokeAlign: 1,
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: GoogleFonts.nunito(
              fontSize: isMobile ? 16 : 20,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAddressToPrefs(Address address, context) async {
    final prefs = await SharedPreferences.getInstance();

    final addressList = [
      address.name,
      address.address,
      address.phoneNumber,
      address.pincode,
      address.type,
      address.email,
    ];

    await prefs.setStringList('selected_address', addressList);
    CustomMessenger(
      context: context,
      message: "Address Saved",
      backgroundColor: Colors.green,
      duration: Durations.extralong2,
      textColor: Colors.white,
    ).show();
  }

  Widget _buildAddressCard(
    Address address,
    bool isMobile,
    double screenWidth,
    context,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: isMobile ? 8.0 : 12.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _saveAddressToPrefs(address, context);
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressField(
                  value: address.type,
                  icon: _getTypeIcon(address.type),
                  isMobile: isMobile,
                ),
                const SizedBox(height: 14),
                _buildAddressField(
                  value: address.name,
                  icon: Icons.person,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 14),
                _buildAddressField(
                  value: address.address,
                  icon: Icons.location_on,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 14),
                _buildAddressField(
                  value: address.phoneNumber,
                  icon: Icons.phone,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 14),
                _buildAddressField(
                  value: address.pincode,
                  icon: FontAwesomeIcons.locationArrow,
                  isMobile: isMobile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Home':
        return Icons.home_rounded;
      case 'Office':
        return Icons.work_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildAddressField({
    required String value,
    required IconData icon,
    required bool isMobile,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.backgroundColor,
            size: isMobile ? 18 : 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 13 : 15,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
