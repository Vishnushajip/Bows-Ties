import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class _Message extends StatelessWidget {
  final Color backgroundColor;
  final String? imageUrl;
  final String? text;
  final String time;
  final Alignment alignment;
  final Widget? child;

  const _Message({
    required this.backgroundColor,
    this.imageUrl,
    this.text,
    required this.time,
    required this.alignment,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: alignment == Alignment.centerLeft
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            if (text != null)
              Text(text!, style: GoogleFonts.nunito(fontSize: 14)),
            if (child != null) child!,
            Text(
              time,
              style: GoogleFonts.nunito(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Assuming CustomMessenger is defined elsewhere
class CustomMessenger {
  final Color backgroundColor;
  final Color textColor;
  final BuildContext context;
  final String message;

  CustomMessenger({
    required this.backgroundColor,
    required this.textColor,
    required this.context,
    required this.message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

// Providers for state management
final messageTextProvider = StateProvider<String>((ref) => '');
final isSendingProvider = StateProvider<bool>((ref) => false);

class ChatDialog extends StatefulWidget {
  final String whatsappNumber;
  final String logoPath;
  final String brandName;
  final String replyTimeText;

  const ChatDialog({
    super.key,
    required this.whatsappNumber,
    this.logoPath = "assets/logo.png",
    this.brandName = "Bows & Ties",
    this.replyTimeText = "Typically replies within a day",
  });

  static void show(
    BuildContext context,
    WidgetRef ref, {
    required String whatsappNumber,
    String logoPath = "assets/logo.png",
    String brandName = "Bows & Ties",
    String replyTimeText = "Typically replies within a day",
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChatDialog(
          whatsappNumber: whatsappNumber,
          logoPath: logoPath,
          brandName: brandName,
          replyTimeText: replyTimeText,
        );
      },
    );
  }

  @override
  _ChatDialogState createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  late TextEditingController messageController;
  late String currentTime;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
    currentTime = DateFormat('hh:mm a').format(DateTime.now());
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp(String message, WidgetRef ref) async {
    final Uri whatsapp = Uri.parse(
      "https://wa.me/${widget.whatsappNumber}?text=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(whatsapp)) {
      await launchUrl(whatsapp);
    } else {
      CustomMessenger(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        context: context,
        message: "Could not open WhatsApp",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const whatsappGreen = Color(0xFF075E54);

    return Dialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer(
                builder: (context, ref, _) {
                  final isSending = ref.watch(isSendingProvider);
                  final messageText = ref.watch(messageTextProvider);

                  // Update messageTextProvider when text changes
                  messageController.addListener(() {
                    ref.read(messageTextProvider.notifier).state =
                        messageController.text.trim();
                  });

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: whatsappGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      widget.logoPath,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          widget.brandName,
                                          style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Icons.verified,
                                          color: Colors.blue,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      widget.replyTimeText,
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: -5,
                            right: -5,
                            bottom: 50,
                            child: IconButton(
                              icon: const Icon(
                                FontAwesomeIcons.xmark,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                messageController.clear();
                                ref.read(messageTextProvider.notifier).state =
                                    '';
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Message(
                              backgroundColor: Colors.white,
                              imageUrl:
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRCMDKvDLrPdTJtG5O4y3W61Wdqg20GwOOpUA&s",
                              text: 'Hi there 👋',
                              time: currentTime,
                              alignment: Alignment.centerLeft,
                            ),
                            _Message(
                              backgroundColor: Colors.white,
                              imageUrl:
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:AbnM5Uc1y1x8QzD2v0nABp88LoY72pC9rIl6un__WSC4WayrZnInRT_QGFZdw_JXWOToesfyv8Wh0HFH9_aem_LL8tVkdt3Ja7BH9rlgvz0Q",
                              text: 'How can I help you?',
                              time: currentTime,
                              alignment: Alignment.centerLeft,
                            ),
                            if (messageText.isNotEmpty)
                              _Message(
                                backgroundColor: Colors.white,
                                imageUrl:
                                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:AbnM5Uc1y1x8QzD2v0nABp88LoY72pC9rIl6un__WSC4WayrZnInRT_QGFZdw_JXWOToesfyv8Wh0HFH9_aem_LL8tVkdt3Ja7BH9rlgvz0Q",
                                time: currentTime,
                                alignment: Alignment.centerRight,
                                child:
                                    LoadingAnimationWidget.horizontalRotatingDots(
                                      color: Colors.black,
                                      size: 10,
                                    ),
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      isSending
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    child: TextField(
                                      cursorColor: Colors.black,
                                      controller: messageController,
                                      decoration: const InputDecoration(
                                        hintText: "Type a message...",
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Material(
                                  color: whatsappGreen,
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      final message = messageController.text
                                          .trim();
                                      if (message.isEmpty) return;

                                      ref
                                              .read(isSendingProvider.notifier)
                                              .state =
                                          true;
                                      await _launchWhatsApp(message, ref);
                                      ref
                                              .read(isSendingProvider.notifier)
                                              .state =
                                          false;
                                      messageController.clear();
                                      ref
                                              .read(
                                                messageTextProvider.notifier,
                                              )
                                              .state =
                                          '';
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
