import 'package:bowsandties/Components/App_Colors.dart';
import 'package:bowsandties/Search/Pages/Typo_Head.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsHome extends ConsumerWidget {
  const DetailsHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Search",
          style: GoogleFonts.nunito(color: AppColors.primaryColor),
        ),
        backgroundColor: Colors.white,
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,

      body: const SafeArea(
        child: SingleChildScrollView(child: Column(children: [SearchBarall()])),
      ),
    );
  }
}
