import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/response_model.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/features/profile/domain/models/userinfo_model.dart';
import 'package:flutter_grocery/features/profile/widgets/profile_text_field.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/profile/widgets/profile_menu_web_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  TextEditingController? _firstNameController;
  TextEditingController? _lastNameController;
  TextEditingController? _emailController;
  TextEditingController? _phoneController;
  TextEditingController? _passwordController;
  TextEditingController? _confirmPasswordController;

  FocusNode? firstNameFocus;
  FocusNode? lastNameFocus;
  FocusNode? emailFocus;
  FocusNode? phoneFocus;
  FocusNode? passwordFocus;
  FocusNode? confirmPasswordFocus;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _initLoading();
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: ColorResources.scaffoldGrey,
      key: _scaffoldKey,
      appBar: ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(
              preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
          : AppBar(
              backgroundColor: Theme.of(context).cardColor,
              leading: GestureDetector(
                onTap: () {
                  splashProvider.setPageIndex(0);
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.chevron_left,
                  size: 30,
                ),
              ),
              centerTitle: true,
              title: Text(
                getTranslated('profile', context),
                style: poppinsSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
      body: ResponsiveHelper.isDesktop(context)
          ? Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
              return ProfileMenuWebWidget(
                file: profileProvider.data,
                pickImage: profileProvider.pickImage,
                confirmPasswordController: _confirmPasswordController,
                confirmPasswordFocus: confirmPasswordFocus,
                emailController: _emailController,
                firstNameController: _firstNameController,
                firstNameFocus: firstNameFocus,
                lastNameController: _lastNameController,
                lastNameFocus: lastNameFocus,
                emailFocus: emailFocus,
                passwordController: _passwordController,
                passwordFocus: passwordFocus,
                phoneNumberController: _phoneController,
                phoneNumberFocus: phoneFocus,
                image: profileProvider.userInfoModel?.image,
                userInfoModel: profileProvider.userInfoModel,
              );
            })
          : SafeArea(child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Center(
                  child: SizedBox(
                    width: Dimensions.webScreenWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // for profile image
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  margin:
                                      const EdgeInsets.only(top: 25, bottom: 8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color:
                                          ColorResources.getGreyColor(context),
                                      width: 3,
                                    ),
                                  ),
                                  child: profileProvider.file != null
                                      ? Image.file(
                                          profileProvider.file!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.fill,
                                        )
                                      : profileProvider.data != null
                                          ? Image.network(
                                              profileProvider.data!.path,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.fill,
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: CustomImageWidget(
                                                placeholder: Images.placeHolder,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                                image:
                                                    '${splashProvider.baseUrls!.customerImageUrl}'
                                                    '/${profileProvider.userInfoModel!.image}',
                                              ),
                                            ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (ResponsiveHelper.isMobilePhone()) {
                                  profileProvider.choosePhoto();
                                } else {
                                  profileProvider.pickImage();
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/edit_profile.svg',
                                    height: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    getTranslated("Edit Photo", context),
                                    style: poppinsMedium.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            //mobileNumber,email,gender
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // for first name section
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Text(
                                          getTranslated('first_name', context),
                                          style: poppinsRegular.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      ProfileTextField(
                                        hintText: getTranslated(
                                            'enter_first_name', context),
                                        isElevation: false,
                                        isPadding: false,
                                        controller: _firstNameController,
                                        focusNode: firstNameFocus,
                                        fillColor: const Color(0xFFF5F5F5),
                                        nextFocus: lastNameFocus,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeDefault),

                                  // for Last name section
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Text(
                                          getTranslated('last_name', context),
                                          style: poppinsRegular.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      ProfileTextField(
                                        hintText: getTranslated(
                                            'enter_last_name', context),
                                        isElevation: false,
                                        isPadding: false,
                                        fillColor: const Color(0xFFF5F5F5),
                                        controller: _lastNameController,
                                        focusNode: lastNameFocus,
                                        nextFocus: emailFocus,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeDefault),
                                  // for email section
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      getTranslated('email', context),
                                      style: poppinsRegular.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  ProfileTextField(
                                    hintText: getTranslated(
                                        'enter_email_address', context),
                                    isElevation: false,
                                    isPadding: false,
                                    isEnabled: false,
                                    fillColor: const Color(0xFFF5F5F5),
                                    controller: _emailController,
                                    focusNode: emailFocus,
                                    nextFocus: phoneFocus,
                                    inputType: TextInputType.emailAddress,
                                  ),

                                  const SizedBox(
                                      height: Dimensions.paddingSizeDefault),
                                  // for Phone Number section
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Text(
                                          getTranslated(
                                              'phone_number', context),
                                          style: poppinsRegular.copyWith(
                                            fontSize: Dimensions.fontSizeLarge,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      ProfileTextField(
                                        hintText: getTranslated(
                                            'enter_phone_number', context),
                                        isElevation: false,
                                        isEnabled: false,
                                        isPadding: false,
                                        fillColor: const Color(0xFFF5F5F5),
                                        controller: _phoneController,
                                        focusNode: phoneFocus,
                                        nextFocus: passwordFocus,
                                        inputType: TextInputType.phone,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeDefault),

                                  //   if (profileProvider.userInfoModel?.loginMedium ==
                                  //       'general')
                                  //     Column(children: [
                                  //       Stack(children: [
                                  //         Column(
                                  //           crossAxisAlignment:
                                  //               CrossAxisAlignment.start,
                                  //           children: [
                                  //             Padding(
                                  //               padding: const EdgeInsets.symmetric(
                                  //                   horizontal: 20),
                                  //               child: Text(
                                  //                 getTranslated('password', context),
                                  //                 style: poppinsRegular.copyWith(
                                  //                   fontSize:
                                  //                       Dimensions.fontSizeLarge,
                                  //                   color: Colors.black,
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //             ProfileTextField(
                                  //               hintText: getTranslated(
                                  //                   'password_hint', context),
                                  //               isElevation: false,
                                  //               isPadding: false,
                                  //               isPassword: true,
                                  //               isShowSuffixIcon: true,
                                  //               controller: _passwordController,
                                  //               focusNode: passwordFocus,
                                  //               nextFocus: confirmPasswordFocus,
                                  //             ),
                                  //           ],
                                  //         ),
                                  //         const Positioned(
                                  //             bottom: 0,
                                  //             left: Dimensions.paddingSizeLarge,
                                  //             right: Dimensions.paddingSizeLarge,
                                  //             child: Divider()),
                                  //       ]),
                                  //       const SizedBox(
                                  //           height: Dimensions.paddingSizeDefault),
                                  //       Stack(children: [
                                  //         Column(
                                  //           crossAxisAlignment:
                                  //               CrossAxisAlignment.start,
                                  //           children: [
                                  //             Padding(
                                  //               padding: const EdgeInsets.symmetric(
                                  //                   horizontal: 20),
                                  //               child: Text(
                                  //                 getTranslated(
                                  //                     'confirm_password', context),
                                  //                 style: poppinsRegular.copyWith(
                                  //                   fontSize:
                                  //                       Dimensions.fontSizeLarge,
                                  //                   color: Colors.black,
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //             ProfileTextField(
                                  //               hintText: getTranslated(
                                  //                   'password_hint', context),
                                  //               isElevation: false,
                                  //               isPadding: false,
                                  //               isPassword: true,
                                  //               isShowSuffixIcon: true,
                                  //               controller:
                                  //                   _confirmPasswordController,
                                  //               focusNode: confirmPasswordFocus,
                                  //               inputAction: TextInputAction.done,
                                  //             ),
                                  //           ],
                                  //         ),
                                  //         const Positioned(
                                  //             bottom: 0,
                                  //             left: Dimensions.paddingSizeLarge,
                                  //             right: Dimensions.paddingSizeLarge,
                                  //             child: Divider()),
                                  //       ]),
                                  //     ]),
                                ]),
                            const SizedBox(height: 50),

                            !profileProvider.isLoading &&
                                    profileProvider.userInfoModel != null
                                ? TextButton(
                                    onPressed: () async {
                                      await _onSubmit();
                                      Provider.of<ProfileProvider>(context,
                                              listen: false)
                                          .getUserInfo();
                                    },
                                    child: Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          getTranslated(
                                              'update_profile', context),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                Dimensions.paddingSizeDefault,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: CustomLoaderWidget(
                                        color: Theme.of(context).primaryColor)),
                            const SizedBox(height: 8),

                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     SvgPicture.asset('assets/svg/delete.svg'),
                            //     const SizedBox(width: 8),
                            //     Text(
                            //       'Delete Account',
                            //       style: poppinsMedium.copyWith(
                            //         color: const Color(0xFF939393),
                            //       ),
                            //     )
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })),
    );
  }

  Future<void> _initLoading() async {
    final ProfileProvider profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    if (profileProvider.userInfoModel == null) {
      await profileProvider.getUserInfo();
    }

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    firstNameFocus = FocusNode();
    lastNameFocus = FocusNode();
    emailFocus = FocusNode();
    phoneFocus = FocusNode();
    passwordFocus = FocusNode();
    confirmPasswordFocus = FocusNode();

    _firstNameController?.text = profileProvider.userInfoModel?.fName ?? '';
    _lastNameController?.text = profileProvider.userInfoModel?.lName ?? '';
    _emailController?.text = profileProvider.userInfoModel?.email ?? '';
    _phoneController?.text = profileProvider.userInfoModel?.phone ?? '';
  }

  Future<void> _onSubmit() async {
    final ProfileProvider profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    print('-----------token-${authProvider.getUserToken()}');
    String firstName = _firstNameController?.text.trim() ?? '';
    String lastName = _lastNameController?.text.trim() ?? '';
    String phoneNumber = _phoneController?.text.trim() ?? '';
    String password = _passwordController?.text.trim() ?? '';
    String confirmPassword = _confirmPasswordController?.text.trim() ?? '';
    if (profileProvider.userInfoModel?.fName == firstName &&
        profileProvider.userInfoModel?.lName == lastName &&
        profileProvider.userInfoModel?.phone == phoneNumber &&
        profileProvider.userInfoModel?.email == _emailController?.text &&
        profileProvider.file == null &&
        profileProvider.data == null &&
        password.isEmpty &&
        confirmPassword.isEmpty) {
      showCustomSnackBarHelper(
          getTranslated('change_something_to_update', context));
    } else if (firstName.isEmpty) {
      showCustomSnackBarHelper(getTranslated('enter_first_name', context));
    } else if (lastName.isEmpty) {
      showCustomSnackBarHelper(getTranslated('enter_last_name', context));
    } else if (phoneNumber.isEmpty) {
      showCustomSnackBarHelper(getTranslated('enter_phone_number', context));
    } else if ((password.isNotEmpty && password.length < 6) ||
        (confirmPassword.isNotEmpty && confirmPassword.length < 6)) {
      showCustomSnackBarHelper(getTranslated('password_should_be', context));
    } //else if (password != confirmPassword) {
    //   showCustomSnackBarHelper(
    //       getTranslated('password_did_not_match', context));
    // }
    else {
      UserInfoModel? updateUserInfoModel = profileProvider.userInfoModel;
      updateUserInfoModel?.fName = _firstNameController?.text;
      updateUserInfoModel?.lName = _lastNameController?.text;
      updateUserInfoModel?.phone = _phoneController?.text;

      ResponseModel responseModel = await profileProvider.updateUserInfo(
        updateUserInfoModel!,
        password,
        profileProvider.file,
        //       profileProvider.data,
        authProvider.getUserToken(),
      );

      if (responseModel.isSuccess) {
        profileProvider.getUserInfo();
        _passwordController?.text = '';
        _confirmPasswordController?.text = '';

        showCustomSnackBarHelper('updated_successfully'.tr, isError: false);
      } else {
        showCustomSnackBarHelper(responseModel.message!, isError: true);
      }
      setState(() {});
    }
  }
}
