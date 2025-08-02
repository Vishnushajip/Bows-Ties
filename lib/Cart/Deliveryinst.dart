import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryInstructionsSection extends ConsumerStatefulWidget {
  const DeliveryInstructionsSection({super.key});

  @override
  ConsumerState<DeliveryInstructionsSection> createState() =>
      _DeliveryInstructionsSectionState();
}

class _DeliveryInstructionsSectionState
    extends ConsumerState<DeliveryInstructionsSection> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _textController.removeListener(_handleTextChange);
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleTextChange() async {
    final prefs = await SharedPreferences.getInstance();
    final text = _textController.text.trim();
    if (text.isEmpty) {
      await prefs.remove('deliveryInstructions');
      print('Cleared text instruction.');
    } else {
      await prefs.setString('deliveryInstructions', text);
      print('Saved text instruction: $text');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Instructions',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _textController,
              textAlign: TextAlign.start,
              maxLines: 2,
              maxLength: 150,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: "Eg: Include an extra button inside",
                hintStyle: GoogleFonts.nunito(),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
