import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void sharePropertyOnWhatsApp({
  required String name,
  required String price,
  required String Id,
  required String imageUrl,
}) async {
  final link = 'https://bowsandties.in/$Id';

  final message = Uri.encodeComponent(
    '''
Check out this From Bows & Ties

$name
Price: $price

See more: $link
''',
  );

  final url = "https://wa.me/?text=$message";

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    debugPrint("Could not launch WhatsApp");
  }
}



