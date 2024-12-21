import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsApp() async {
  final whatsappUrl = Uri.parse('https://wa.me/+97433834376');

  await launchUrl(whatsappUrl);
}
