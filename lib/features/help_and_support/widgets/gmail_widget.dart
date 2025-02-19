import 'package:url_launcher/url_launcher.dart';

Future<void> openGmail() async {
  final emailUri = Uri(
    scheme: 'mailto',
    path: 'Customercare@keakado.com',
    // query:
    //     'subject=Your Subject&body=Hello, this is the email body', // Optional query parameters
  );

  await launchUrl(emailUri);
}
