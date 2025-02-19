import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/common/models/error_response_model.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/common/models/response_model.dart';
import 'package:flutter_grocery/features/auth/domain/models/signup_model.dart';
import 'package:flutter_grocery/features/auth/domain/models/user_log_data.dart';
import 'package:flutter_grocery/features/auth/domain/models/social_login_model.dart';
import 'package:flutter_grocery/features/auth/domain/reposotories/auth_repo.dart';
import 'package:flutter_grocery/features/auth/domain/reposotories/delete_account_repo.dart';
import 'package:flutter_grocery/features/auth/providers/verification_provider.dart';
import 'package:flutter_grocery/features/auth/screens/login_menu_screen.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/features/wishlist/providers/wishlist_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../../helper/api_checker_helper.dart';
import '../screens/login_screen.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepo? authRepo;

  AuthProvider({required this.authRepo});

  bool _isLoading = false;
  bool _isCheckedPhone = false;
  String? _registrationErrorMessage = '';
  bool _isActiveRememberMe = false;
  String? _loginErrorMessage = '';
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool get isLoading => _isLoading;
  bool get isCheckedPhone => _isCheckedPhone;
  String? get registrationErrorMessage => _registrationErrorMessage;
  bool get isActiveRememberMe => _isActiveRememberMe;
  String? get loginErrorMessage => _loginErrorMessage;
  GoogleSignInAccount? googleAccount;

  void updateRegistrationErrorMessage(String message, bool isUpdate) {
    _registrationErrorMessage = message;

    if (isUpdate) {
      notifyListeners();
    }
  }

  Future<ResponseModel> registration(
      SignUpModel signUpModel, ConfigModel config) async {
    final VerificationProvider verificationProvider =
        Provider.of<VerificationProvider>(Get.context!, listen: false);

    _isLoading = true;
    _isCheckedPhone = false;
    _registrationErrorMessage = '';
    notifyListeners();
    ApiResponseModel apiResponse = await authRepo!.registration(signUpModel);
    ResponseModel responseModel;
    String? token;
    String? tempToken;

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      showCustomSnackBarHelper(
          getTranslated('registration_successful', Get.context!),
          isError: false);

      Map map = apiResponse.response!.data;
      if (map.containsKey('temporary_token')) {
        tempToken = map["temporary_token"];
      } else if (map.containsKey('token')) {
        token = map["token"];
      }

      if (token != null) {
        await login(signUpModel.email, signUpModel.password);
        responseModel = ResponseModel(true, 'successful');
      } else {
        _isCheckedPhone = true;
        verificationProvider.sendVerificationCode(config, signUpModel);
        responseModel = ResponseModel(false, tempToken);
      }
    } else {
      _registrationErrorMessage =
          ErrorResponseModel.fromJson(apiResponse.error).errors![0].message;
      responseModel = ResponseModel(false, _registrationErrorMessage);
    }
    _isLoading = false;
    notifyListeners();

    return responseModel;
  }

  Future<ResponseModel> login(String? email, String? password) async {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(Get.context!, listen: false);
    final VerificationProvider verificationProvider =
        Provider.of<VerificationProvider>(Get.context!, listen: false);

    _isLoading = true;
    _loginErrorMessage = '';
    notifyListeners();
    ApiResponseModel apiResponse =
        await authRepo!.login(email: email, password: password);
    ResponseModel responseModel;
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      String? token;
      String? tempToken;
      Map map = apiResponse.response!.data;
      if (map.containsKey('temporary_token')) {
        tempToken = map["temporary_token"];
      } else if (map.containsKey('token')) {
        token = map["token"];
      }
      if (token != null) {
        await updateAuthToken(token);
      } else if (tempToken != null) {
        await verificationProvider.sendVerificationCode(
            splashProvider.configModel!,
            SignUpModel(email: email, phone: email));
      }

      responseModel = ResponseModel(token != null, 'verification');
    } else {
      _loginErrorMessage =
          ErrorResponseModel.fromJson(apiResponse.error).errors![0].message;
      responseModel = ResponseModel(false, _loginErrorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> sendOtp(String phone) async {
    _isLoading = true;
    _loginErrorMessage = '';
    notifyListeners();
    if (phone.trim().isEmpty) {
      _loginErrorMessage = "Phone number is required";
      _isLoading = false;
      notifyListeners();

      return ResponseModel(false, "Mobile number is required");
    } else {
      _loginErrorMessage = '';
    }
    ApiResponseModel apiResponse = await authRepo!.sendOtp(phone: phone);
    ResponseModel responseModel;
    log((apiResponse.response?.statusCode ?? 0).toString(),
        name: "Status Code");
    log((apiResponse.response?.data ?? 0).toString(), name: "Response");
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, 'send_otp');
      _loginErrorMessage = '';
    } else {
      try {
        _loginErrorMessage =
            ErrorResponseModel.fromJson(apiResponse.error).errors![0].message;
        responseModel = ResponseModel(false, _loginErrorMessage);
      } catch (e) {
        _loginErrorMessage = "Invalid mobile number";
        responseModel = ResponseModel(false, _loginErrorMessage);
      }
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> verifyOtp(
      {required String phone, required String otp}) async {
    _isLoading = true;
    _loginErrorMessage = '';
    notifyListeners();
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(Get.context!, listen: false);
    final VerificationProvider verificationProvider =
        Provider.of<VerificationProvider>(Get.context!, listen: false);
    ApiResponseModel apiResponse =
        await authRepo!.verifyOtp(phone: phone, otp: otp);
    ResponseModel responseModel;
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      if (apiResponse.response?.data['message'] == "new user") {
        responseModel = ResponseModel(true, 'new_user');
      } else {
        String? token;
        String? tempToken;
        Map map = apiResponse.response!.data;
        if (map.containsKey('temporary_token')) {
          tempToken = map["temporary_token"];
        } else if (map.containsKey('token')) {
          token = map["token"];
        }
        if (token != null) {
          await updateAuthToken(token);
        } else if (tempToken != null) {
          await verificationProvider.sendVerificationCode(
              splashProvider.configModel!, SignUpModel(phone: phone));
        }

        responseModel = ResponseModel(token != null, 'verification');
      }
      _loginErrorMessage = '';
    } else {
      try {
        _loginErrorMessage = apiResponse.response?.data[
            "message"]; // ErrorResponseModel.fromJson(apiResponse.error).errors![0].message;
        responseModel = ResponseModel(false, _loginErrorMessage);
      } catch (e) {
        _loginErrorMessage = "Unable to verify OTP";
        responseModel = ResponseModel(false, _loginErrorMessage);
      }
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> createProfile(
      {required String phone,
      required String firstName,
      required String lastName,
      required String email,
      String? referral}) async {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(Get.context!, listen: false);
    final VerificationProvider verificationProvider =
        Provider.of<VerificationProvider>(Get.context!, listen: false);
    _isLoading = true;
    _loginErrorMessage = '';
    notifyListeners();
    ApiResponseModel apiResponse = await authRepo!.createProfile(
      referral: referral,
      phone: phone,
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
    ResponseModel responseModel;
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      String? token;
      String? tempToken;
      Map map = apiResponse.response!.data;
      if (map.containsKey('temporary_token')) {
        tempToken = map["temporary_token"];
      } else if (map.containsKey('token')) {
        token = map["token"];
      }
      if (token != null) {
        await updateAuthToken(token);
      } else if (tempToken != null) {
        await verificationProvider.sendVerificationCode(
            splashProvider.configModel!,
            SignUpModel(email: email, phone: email));
      }

      responseModel = ResponseModel(token != null, 'verification');
      _loginErrorMessage = '';
    } else {
      _loginErrorMessage =
          ErrorResponseModel.fromJson(apiResponse.error).errors![0].message;
      responseModel = ResponseModel(false, _loginErrorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<void> deleteUser(BuildContext context) async {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);
    _isLoading = true;
    notifyListeners();
    ApiResponseModel? response = await authRepo?.deleteUser();
    _isLoading = false;

    if (response?.response?.statusCode == 200) {
      splashProvider.removeSharedData();
      showCustomSnackBarHelper('your_account_remove_successfully'.tr);
      Navigator.pushAndRemoveUntil(
          Get.context!,
          MaterialPageRoute(builder: (_) => const LoginMenuScreen()),
          (route) => false);
    } else {
      Navigator.of(Get.context!).pop();
      ApiCheckerHelper.checkApi(response!);
    }
  }

  // for forgot password

  Future<ResponseModel> forgetPassword(String? email) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await authRepo!.forgetPassword(email);
    ResponseModel responseModel;

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      responseModel =
          ResponseModel(true, apiResponse.response!.data["message"]);
    } else {
      responseModel = ResponseModel(false,
          ErrorResponseModel.fromJson(apiResponse.error).errors![0].message);
    }
    _isLoading = false;
    notifyListeners();

    return responseModel;
  }

  Future<ResponseModel> resetPassword(String? mail, String? resetToken,
      String password, String confirmPassword) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await authRepo!
        .resetPassword(mail, resetToken, password, confirmPassword);
    _isLoading = false;
    notifyListeners();
    ResponseModel responseModel;
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      responseModel =
          ResponseModel(true, apiResponse.response!.data["message"]);
    } else {
      responseModel = ResponseModel(false,
          ErrorResponseModel.fromJson(apiResponse.error).errors![0].message);
    }
    return responseModel;
  }

  Future<void> updateToken() async {
    await authRepo?.updateToken();
  }

  void onChangeRememberMeStatus({bool? value}) {
    if (value == null) {
      _isActiveRememberMe = !_isActiveRememberMe;
    } else {
      _isActiveRememberMe = value;
    }
    notifyListeners();
  }

  bool isLoggedIn() {
    return authRepo!.isLoggedIn();
  }

  Future<bool> clearSharedData() async {
    return await authRepo!.clearSharedData();
  }

  void saveUserNumberAndPassword(UserLogData userLogData) {
    authRepo!.saveUserNumberAndPassword(jsonEncode(userLogData.toJson()));
  }

  UserLogData? getUserData() {
    UserLogData? userData;
    try {
      userData = UserLogData.fromJson(jsonDecode(authRepo!.getUserLogData()));
    } catch (error) {
      debugPrint('error ====> $error');
    }
    return userData;
  }

  Future<bool> clearUserLogData() async {
    return authRepo!.clearUserLog();
  }

  String getUserToken() {
    return authRepo!.getUserToken();
  }

  Future<GoogleSignInAuthentication> googleLogin() async {
    GoogleSignInAuthentication auth;
    googleAccount = await _googleSignIn.signIn();
    auth = await googleAccount!.authentication;
    return auth;
  }

  Future socialLogin(SocialLoginModel socialLogin, Function callback) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await authRepo!.socialLogin(socialLogin);
    _isLoading = false;
    if (apiResponse.response?.statusCode == 200) {
      Map map = apiResponse.response!.data;
      String? message = '';
      String? token = '';
      try {
        message = map['error_message'] ?? '';
      } catch (_) {}
      try {
        token = map['token'];
      } catch (_) {}

      // if (token != null) {
      //   authRepo!.saveUserToken(token);
      //   await updateFirebaseToken();
      // }

      callback(true, token, message);
      notifyListeners();
    } else {
      notifyListeners();
      callback(false, '',
          ApiCheckerHelper.getError(apiResponse).errors?.first.message);
    }
  }

  Future<void> socialLogout() async {
    try {
      // final GoogleSignIn googleSignIn = GoogleSignIn();
      // googleSignIn.disconnect();
      GoogleSignIn().signOut();

      await FacebookAuth.instance.logOut();
    } catch (_) {}
  }

  // Future updateFirebaseToken() async {
  //   if (await authRepo!.getDeviceToken() != '@') {
  //     await authRepo!.updateToken();
  //   }
  // }

  // Future<void> addOrUpdateGuest() async {
  //   String? fcmToken = await authRepo?.getDeviceToken();
  //   ApiResponseModel apiResponse = await authRepo!.addOrUpdateGuest(fcmToken);

  //   if (apiResponse.response != null &&
  //       apiResponse.response!.statusCode == 200 &&
  //       apiResponse.response?.data != null &&
  //       apiResponse.response?.data.isNotEmpty &&
  //       apiResponse.response?.data['guest']['id'] != null) {
  //     authRepo?.saveGuestId(
  //         '${apiResponse.response?.data['guest']['id'].toString()}');
  //   }
  // }

  String? getGuestId() => isLoggedIn() ? null : authRepo?.getGuestId();

  Future<void> firebaseOtpLogin(
      {required String phoneNumber,
      required String session,
      required String otp,
      bool isForgetPassword = false}) async {
    _isLoading = true;
    notifyListeners();
    ApiResponseModel apiResponse = await authRepo!.firebaseAuthVerify(
      session: session,
      phoneNumber: phoneNumber,
      otp: otp,
      isForgetPassword: isForgetPassword,
    );

    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      String? token;
      String? tempToken;

      try {
        token = map["token"];
        tempToken = map["temp_token"];
      } catch (_) {}

      if (isForgetPassword) {
        Navigator.of(Get.context!)
            .pushNamed(RouteHelper.getNewPassRoute(phoneNumber, otp));
      } else {
        if (token != null) {
          await updateAuthToken(token);
          Navigator.pushReplacementNamed(
              Get.context!, RouteHelper.getMainRoute());
        } else if (tempToken != null) {
          Navigator.of(Get.context!).pushNamed(RouteHelper.getCreateAccount());
        }
      }
    } else {
      ApiCheckerHelper.checkApi(apiResponse);
    }

    _isLoading = false;
    notifyListeners();
  }

  void onChangeLoadingStatus() {
    _isLoading = false;
  }

  Future<void> updateAuthToken(String token) async {
    authRepo!.saveUserToken(token);
    await authRepo!.updateToken();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(Get.context!, listen: false);
    final WishListProvider wishListProvider =
        Provider.of<WishListProvider>(Get.context!, listen: false);
    final CartProvider cartProvider =
        Provider.of<CartProvider>(Get.context!, listen: false);

    clearSharedData().then((value) {
      authRepo?.clearToken();
      cartProvider.getCartData(isUpdate: true);
      splashProvider.setPageIndex(0);
      socialLogout();
      wishListProvider.clearWishList();
      //  addOrUpdateGuest();
    });
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteAccount(String token) async {
    try {
      _isLoading = true;
      notifyListeners();

      final bool deleted = await deleteAccountApi(token);
      if (!deleted) {
        return deleted;
      }
      // Get providers
      final splashProvider =
          Provider.of<SplashProvider>(Get.context!, listen: false);
      final wishListProvider =
          Provider.of<WishListProvider>(Get.context!, listen: false);
      final cartProvider =
          Provider.of<CartProvider>(Get.context!, listen: false);

      // Clear data
      await clearSharedData();
      await authRepo?.clearToken();
      await socialLogout();

      // Update UI state
      cartProvider.getCartData(isUpdate: true);
      splashProvider.setPageIndex(0);
      wishListProvider.clearWishList();
      return deleted;
    } catch (e) {
      // Handle errors
      showCustomSnackBarHelper('Error deleting account: $e', isError: true);
      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }
  // Future<void> deleteAccount(String token) async {
  //   _isLoading = true;
  //   notifyListeners();
  //   bool deleted = await deleteAccountApi(token);
  //   print('-----------deleted acc----$deleted');
  //   if (deleted == false) {
  //     return showCustomSnackBarHelper('Complete your ruuning Orders'.tr,
  //         isError: false);
  //   }
  //   final SplashProvider splashProvider =
  //       Provider.of<SplashProvider>(Get.context!, listen: false);
  //   final WishListProvider wishListProvider =
  //       Provider.of<WishListProvider>(Get.context!, listen: false);
  //   final CartProvider cartProvider =
  //       Provider.of<CartProvider>(Get.context!, listen: false);
  //   // bool deleted = await deleteAccountApi(token);
  //   // print('-----------deleted acc----$deleted');
  //   // if (deleted == false) {
  //   //   return showCustomSnackBarHelper('Complete your ruuning Orders'.tr,
  //   //       isError: false);
  //   // }
  //   clearSharedData().then((value) {
  //     authRepo?.clearToken();
  //     cartProvider.getCartData(isUpdate: true);
  //     splashProvider.setPageIndex(0);
  //     socialLogout();
  //     wishListProvider.clearWishList();
  //     //   addOrUpdateGuest();
  //   });
  //   _isLoading = false;
  //   notifyListeners();
  // }
}
