import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_text_field_widget.dart';
import 'package:flutter_grocery/features/auth/domain/models/user_log_data.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/auth/widgets/country_code_picker_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({Key? key}) : super(key: key);

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final FocusNode _numberFocus = FocusNode();
  TextEditingController phoneController = TextEditingController();
  String? countryCode;
  late AuthProvider authProvider;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);

    UserLogData? userData = authProvider.getUserData();
    if (userData != null && countryCode != null) {
      countryCode = userData.countryCode;
    }
    final ConfigModel configModel =
        Provider.of<SplashProvider>(context, listen: false).configModel!;
    countryCode ??= CountryCode.fromCountryCode(configModel.country!).dialCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 65),
                    const Text(
                      'Hi ! Welcome back to\nKeakado',
                      style: TextStyle(
                        color: Color(0xFF133051),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getTranslated("Create your account now!", context),
                      style: const TextStyle(
                        color: Color(0xFF252525),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Text(
                      getTranslated('Enter your mobile number', context),
                      style: poppinsMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CountryCodePickerWidget(
                          hideMainText: true,
                          onChanged: (CountryCode value) {
                            countryCode = value.dialCode;
                          },
                          initialSelection: countryCode,
                          favorite: [countryCode!],
                          showDropDownButton: true,
                          padding: EdgeInsets.zero,
                          showFlagMain: true,
                          textStyle: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.color),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.height * 0.02),
                        Expanded(
                          child: CustomTextFieldWidget(
                            hintText: getTranslated('number_hint', context),
                            isShowBorder: true,
                            focusNode: _numberFocus,
                            fillColor: const Color(0xFFF5F5F5),
                            controller: phoneController,
                            inputType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (authProvider.loginErrorMessage != null &&
                        authProvider.loginErrorMessage != '')
                      Text(
                        authProvider.loginErrorMessage!,
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      Text(
                        getTranslated(
                            "Securing your personal information is our priority",
                            context),
                        style: poppinsMedium,
                      ),
                  ],
                ),
                Column(
                  children: [
                    CustomButtonWidget(
                      isLoading: authProvider.isLoading,
                      buttonText: getTranslated("Get Otp", context),
                      onPressed: () {
                        authProvider.sendOtp(phoneController.text.trim()).then(
                          (value) {
                            if (value.isSuccess) {
                              Navigator.of(context).pushNamed(
                                RouteHelper.getOtpRoute(
                                  phoneController.text.trim(),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ],
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
