import 'package:bowsandties/Services/Utlies.dart/chat_dialog_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactMenuButton extends ConsumerWidget {
  const ContactMenuButton({super.key});

  void _openEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'bowsandties2418@gmail.com',
    );
    await launchUrl(emailLaunchUri);
  }

  void _openInstagram() async {
    final Uri instagramUri = Uri.parse('https://instagram.com/bowsandties2418');
    if (await canLaunchUrl(instagramUri)) {
      await launchUrl(instagramUri, mode: LaunchMode.externalApplication);
    }
  }

  void _makeCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '9061888369');
    await launchUrl(phoneUri);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SpeedDial(
      icon: CupertinoIcons.chat_bubble_2_fill,
      activeIcon: Icons.close,
      foregroundColor: Colors.white,
      activeForegroundColor: Colors.red,
      backgroundColor: Colors.black,
      animationDuration: Durations.extralong1,
      overlayOpacity: 0.5,
      children: [
        SpeedDialChild(
          labelStyle: GoogleFonts.nunito(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          shape: const CircleBorder(),
          child: const Icon(Icons.email, color: Colors.white),
          backgroundColor: Colors.red,
          label: 'Email',
          onTap: _openEmail,
        ),
        SpeedDialChild(
          shape: const CircleBorder(),
          child: const Icon(Icons.call, color: Colors.white),
          backgroundColor: Colors.green,
          label: 'Call',
          labelStyle: GoogleFonts.nunito(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          onTap: _makeCall,
        ),
        SpeedDialChild(
          labelStyle: GoogleFonts.nunito(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          shape: const CircleBorder(),
          child: const Icon(FontAwesomeIcons.instagram, color: Colors.white),
          backgroundColor: Colors.purple,
          label: 'Instagram',
          onTap: _openInstagram,
        ),
        SpeedDialChild(
          labelStyle: GoogleFonts.nunito(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          shape: const CircleBorder(),
          child: const Icon(FontAwesomeIcons.whatsapp, color: Colors.white),
          backgroundColor: Colors.green,
          label: 'WhatsApp',
          onTap: () => showChatDialog(context, ref),
        ),
      ],
    );
  }
}
