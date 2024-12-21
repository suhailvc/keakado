import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/help_and_support/screens/support_form.dart';
import 'package:flutter_grocery/features/help_and_support/widgets/gmail_widget.dart';
import 'package:flutter_grocery/features/help_and_support/widgets/whats_app_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(60, 231, 229, 229),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Help & Support'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFBEBEBE),
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Text(
                      'Contact Form',
                      style: TextStyle(
                        color: const Color(0xFF9A9A9A),
                        fontSize: screenWidth * 0.039,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Image.asset(
                      'assets/image/contact_form_icon.png',
                      width: screenWidth * 0.06,
                      height: screenWidth * 0.06,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactScreen(),
                          ));
                    },
                  ),
                  const Divider(color: Color(0xFFBEBEBE)),
                  ListTile(
                    leading: Text(
                      'Connect with us via WhatsApp',
                      style: TextStyle(
                        color: const Color(0xFF9A9A9A),
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.green,
                      size: screenWidth * 0.06,
                    ),
                    onTap: () async {
                      await openWhatsApp();
                    },
                  ),
                  const Divider(color: Color(0xFFBEBEBE)),
                  ListTile(
                    leading: Text(
                      'Connect with us via Mail',
                      style: TextStyle(
                        color: const Color(0xFF9A9A9A),
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Image.asset(
                      'assets/image/gmail_icon.png',
                      width: screenWidth * 0.06,
                      height: screenWidth * 0.06,
                    ),
                    onTap: () async {
                      await openGmail();
                    },
                  ),
                  const Divider(color: Color(0xFFBEBEBE)),
                  SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: Text(
                      'If any queries contact to this number:',
                      style: TextStyle(
                        color: const Color(0xFF9A9A9A),
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '+974 3383 4376',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
