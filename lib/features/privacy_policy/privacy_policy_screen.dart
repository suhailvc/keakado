import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: getTranslated('Privacy Policy', context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Information We Collect',
              [
                'Name and contact information including email address',
                'Device information and app usage data',
                'Demographic information such as location, preferences and interests',
                'Information relevant to user surveys and offers',
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'How We Use Your Information',
              [
                'Internal record keeping',
                'Improving our app and services',
                'Sending promotional communications about new features, special offers or other relevant information',
                'Market research purposes via email, phone or in-app notifications',
                'Personalizing your app experience based on your preferences',
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Security',
              [
                'We prioritize protecting your information. We implement appropriate technical, physical and administrative safeguards to protect information collected through our app.',
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Data Storage and Cookies',
              [
                'Our app may store certain data locally on your device to improve performance and customize your experience. This includes app settings, cached data, and user preferences. You can clear this data through your device settings, though this may affect app functionality.',
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Managing Your Information',
              [
                'Adjusting app permissions in your device settings',
                'Opting out of marketing communications via app settings',
                'Requesting details of your stored personal information by contacting us',
                'Notifying us of incorrect information that needs updating',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...content.map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(text),
            )),
      ],
    );
  }
}
