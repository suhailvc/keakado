import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/auth/providers/verification_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({Key? key, required this.phone}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final FocusNode otpFocus = FocusNode();
  TextEditingController otpController = TextEditingController();
  late AuthProvider authProvider;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 65),
                    const Text(
                      'Verify Phone',
                      style: TextStyle(
                        color: Color(0xFF133051),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      "Code has been sent to ${widget.phone}",
                      style: poppinsMedium,
                    ),
                    const SizedBox(height: 16),
                    Consumer<VerificationProvider>(
                      builder: (context, verificationProvider, _) {
                        return PinCodeTextField(
                          controller: otpController,
                          length: 4,
                          appContext: context,
                          obscureText: false,
                          enabled: true,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            fieldHeight: 56,
                            fieldWidth: 80,
                            borderWidth: 1,
                            borderRadius: BorderRadius.circular(10),
                            selectedColor:
                                Theme.of(context).primaryColor.withOpacity(1),
                            selectedFillColor: const Color(0xFFF5F5F5),
                            inactiveFillColor: const Color(0xFFF5F5F5),
                            inactiveColor:
                                Theme.of(context).primaryColor.withOpacity(1),
                            activeColor:
                                Theme.of(context).primaryColor.withOpacity(1),
                            activeFillColor: const Color(0xFFF5F5F5),
                          ),
                          cursorColor: Theme.of(context).primaryColor,
                          cursorWidth: 3,
                          animationDuration: const Duration(milliseconds: 300),
                          backgroundColor: Colors.transparent,
                          enableActiveFill: true,
                          onChanged: (query) => verificationProvider
                              .updateVerificationCode(query, 4),
                          beforeTextPaste: (text) {
                            return true;
                          },
                        );
                      },
                    ),
                    if (authProvider.loginErrorMessage != null &&
                        authProvider.loginErrorMessage != '')
                      Text(
                        authProvider.loginErrorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 65),
                    const Text(
                      'Didn’t get OTP code?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        authProvider.sendOtp(widget.phone).then(
                          (value) {
                            if (value.isSuccess) {
                              showCustomSnackBarHelper(
                                "Otp Resend Successfully",
                                isError: false,
                              );
                            } else {
                              showCustomSnackBarHelper(
                                "Otp Resend Failed",
                                isError: true,
                              );
                            }
                          },
                        );
                      },
                      child: Text(
                        'Resend Code',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    CustomButtonWidget(
                      isLoading: authProvider.isLoading,
                      buttonText: getTranslated("continue", context),
                      onPressed: () {
                        authProvider
                            .verifyOtp(
                          phone: widget.phone,
                          otp: otpController.text.trim(),
                        )
                            .then(
                          (status) {
                            if (status.isSuccess &&
                                status.message == "new_user") {
                              Navigator.pushNamed(
                                context,
                                RouteHelper.getCreateProfileRoute(
                                  widget.phone,
                                ),
                              );
                            } else if (status.isSuccess) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, RouteHelper.menu, (route) => false);
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 65),
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
