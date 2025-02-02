import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class CreateProfileScreen extends StatefulWidget {
  final String phone;

  const CreateProfileScreen({Key? key, required this.phone}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode referralFocus = FocusNode();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController referralController = TextEditingController();
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    print('-----------phone${widget.phone}');
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/image/login_background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Consumer<AuthProvider>(builder: (context, authProvider, _) {
            return Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 65),
                      const Text(
                        'Enter your Details Below',
                        style: TextStyle(
                          color: Color(0xFF133051),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        "Enter personal Details",
                        style: poppinsMedium,
                      ),
                      const SizedBox(height: 32),
                      fieldWidget(context, "enter_first_name", "first_name",
                          firstNameController, firstNameFocus, lastNameFocus),
                      fieldWidget(context, "enter_last_name", "last_name",
                          lastNameController, lastNameFocus, emailFocus),
                      fieldWidget(context, "enter_email_address", "Email",
                          emailController, emailFocus, referralFocus),
                      fieldWidget(
                          context,
                          "enter referral",
                          "Referral Code (optional)",
                          referralController,
                          referralFocus,
                          null),
                    ],
                  ),
                  Column(
                    children: [
                      if (authProvider.loginErrorMessage != null &&
                          authProvider.loginErrorMessage != '')
                        Text(
                          authProvider.loginErrorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 8),
                      CustomButtonWidget(
                        isLoading: authProvider.isLoading,
                        buttonText: getTranslated("continue", context),
                        onPressed: () {
                          if (emailController.text.isNotEmpty &&
                              !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(emailController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid email address',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return; // Stop submission if email is invalid
                          }
                          authProvider
                              .createProfile(
                                  phone: widget.phone,
                                  firstName: firstNameController.text.trim(),
                                  lastName: lastNameController.text.trim(),
                                  email: emailController.text.trim(),
                                  referral: referralController.text.trim())
                              .then(
                            (value) {
                              if (value.isSuccess) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  RouteHelper.menu,
                                  (route) =>
                                      false, // Remove all previous routes
                                );
                                // Navigator.of(context)
                                //     .pushNamed(RouteHelper.menu);
                              }
                            },
                          );
                        },
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                    ],
                  )
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  fieldWidget(BuildContext context, String hint, String title,
      TextEditingController controller, FocusNode focus, FocusNode? nextFocus) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTranslated(title, context),
            style: poppinsRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          CustomTextFieldWidget(
            hintText: getTranslated(hint, context),
            isShowBorder: true,
            focusNode: focus,
            fillColor: const Color(0xFFF5F5F5),
            controller: controller,
            nextFocus: nextFocus,
          ),
        ],
      ),
    );
  }
}
