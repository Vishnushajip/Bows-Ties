import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ReusableCountdownDialog extends ConsumerStatefulWidget {
  final BuildContext context;
  final WidgetRef ref;
  final String message;
  final String imagePath;
  final VoidCallback onRedirect;
  final String button;
  final Color color;
  final Color buttonTextColor;
  final Color buttonColor;

  const ReusableCountdownDialog({
    super.key,
    required this.context,
    required this.ref,
    required this.message,
    required this.imagePath,
    required this.onRedirect,
    required this.button,
    required this.color,
    required this.buttonTextColor,
    required this.buttonColor,
  });

  void show() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => this,
    );
  }

  @override
  _ReusableCountdownDialogState createState() => _ReusableCountdownDialogState();
}

class _ReusableCountdownDialogState extends ConsumerState<ReusableCountdownDialog> {
  int _countdown = 5;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        widget.onRedirect();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        width: isMobile ? screenWidth * 0.8 : screenWidth * 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            widget.imagePath.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.imagePath,
                    height: isMobile ? 80 : 100,
                    width: isMobile ? 80 : 100,
                    placeholder: (context, url) => CircularProgressIndicator(
                      color: widget.color,
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error,
                      size: isMobile ? 40 : 50,
                      color: widget.color,
                    ),
                  )
                : Icon(
                    Icons.info,
                    size: isMobile ? 40 : 50,
                    color: widget.color,
                  ),
            const SizedBox(height: 16),
            // Message
            Text(
              widget.message,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF273847),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Countdown
            Text(
              'Redirecting in $_countdown seconds...',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 12 : 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            // Button
            ElevatedButton(
              onPressed: widget.onRedirect,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.buttonColor,
                foregroundColor: widget.buttonTextColor,
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
                widget.button,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}