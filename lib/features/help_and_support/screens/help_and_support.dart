import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/help_and_support/screens/support_form.dart';
import 'package:flutter_grocery/features/help_and_support/widgets/gmail_widget.dart';
import 'package:flutter_grocery/features/help_and_support/widgets/whats_app_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  late LatLng _initialPosition;

  @override
  void initState() {
    super.initState();
    _initializeMapPosition();
  }

  void _initializeMapPosition() {
    final branch = Provider.of<SplashProvider>(context, listen: false)
        .configModel!
        .branches![0];
    _initialPosition = LatLng(
      double.parse(branch.latitude!),
      double.parse(branch.longitude!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(60, 231, 229, 229),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(getTranslated("Help & Support", context)),
        // Text('Help & Support'),
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
                      getTranslated("Contact Form", context),
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
                      getTranslated("Connect with us via WhatsApp", context),
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
                      getTranslated("Connect with us via Mail", context),
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
                      getTranslated(
                          "If any queries contact to this number", context),
                      style: TextStyle(
                        color: const Color(0xFF9A9A9A),
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Center(
                    child: Directionality(
                      textDirection: TextDirection.ltr, // Forces LTR direction
                      child: Text(
                        '+974 3383 4376',
                        style: poppinsRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault),
                      ),
                    ),
                  )
                  // Center(
                  //   child: Text(
                  //     '+974 3383 4376',
                  //     style: poppinsRegular.copyWith(
                  //         fontSize: Dimensions.fontSizeDefault),
                  //   ),
                  // )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    draggable: false,
                    markerId: const MarkerId('branchLocation'),
                    position: _initialPosition,
                    infoWindow: const InfoWindow(
                      title: 'Branch Location',
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
