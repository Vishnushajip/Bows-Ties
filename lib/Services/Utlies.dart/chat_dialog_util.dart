import 'package:bowsandties/Services/Floatingbutton.dart';
import 'package:bowsandties/Services/Scaffold_Messanger.dart';
import 'package:bowsandties/Services/Utlies.dart/Message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

void showChatDialog(BuildContext context, WidgetRef ref) {
  final messageController = TextEditingController();
  final String currentTime = DateFormat('hh:mm a').format(DateTime.now());
  const whatsappGreen = Color(0xFF075E54);
  messageController.addListener(() {
    ref.read(messageTextProvider.notifier).state = messageController.text
        .trim();
  });
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                        "assets/logo.png",
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Bows & Ties',
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
                                        'Typically replies within a day',
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
                                  FontAwesomeIcons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  messageController.clear();
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
                              Message(
                                backgroundColor: Colors.white,
                                imageUrl:
                                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRCMDKvDLrPdTJtG5O4y3W61Wdqg20GwOOpUA&s",
                                text: 'Hi there 👋',
                                time: currentTime,
                                alignment: Alignment.centerLeft,
                              ),
                              Message(
                                backgroundColor: Colors.white,
                                imageUrl:
                                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRCMDKvDLrPdTJtG5O4y3W61Wdqg20GwOOpUA&s",
                                text: 'How can I help you?',
                                time: currentTime,
                                alignment: Alignment.centerLeft,
                              ),
                              if (messageText.isNotEmpty)
                                Message(
                                  backgroundColor: Colors.white,
                                  imageUrl:
                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRH87TKQrWcl19xly2VNs0CjBzy8eaKNM-ZpA&s",
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
                                    color: const Color(0xFF075E54),
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
                                                .read(
                                                  isSendingProvider.notifier,
                                                )
                                                .state =
                                            true;

                                        final Uri whatsapp = Uri.parse(
                                          "https://wa.me/919061888369?text=${Uri.encodeComponent(message)}",
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

                                        ref
                                                .read(
                                                  isSendingProvider.notifier,
                                                )
                                                .state =
                                            false;
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
    },
  );
}
