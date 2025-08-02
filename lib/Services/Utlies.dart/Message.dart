
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Message extends StatelessWidget {
  final String? text;
  final String time;
  final Alignment alignment;
  final String imageUrl;
  final Color? backgroundColor;
  final Widget? child;

  const Message({
    this.text,
    required this.time,
    required this.alignment,
    required this.imageUrl,
    required this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = screenWidth * 0.1;

    final maxMessageWidth = screenWidth * 0.65;

    return Align(
      alignment: alignment,
      child: Row(
        mainAxisAlignment: alignment == Alignment.centerLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: Colors.grey[300],
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (error, stackTrace) {},
            child: imageUrl.isEmpty
                ? Icon(
                    Icons.broken_image,
                    size: avatarSize / 2,
                    color: Colors.grey,
                  )
                : null,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: maxMessageWidth),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: alignment == Alignment.centerLeft
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                child ??
                    Text(
                      text ?? "",
                      style: GoogleFonts.nunito(fontSize: screenWidth * 0.04),
                    ),
                const SizedBox(height: 1),
                Text(
                  time,
                  style: GoogleFonts.nunito(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.022,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
