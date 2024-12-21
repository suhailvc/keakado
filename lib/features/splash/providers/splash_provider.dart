import 'package:flutter/foundation.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/features/order/domain/models/offline_payment_model.dart';
import 'package:flutter_grocery/features/splash/domain/reposotories/splash_repo.dart';
import 'package:flutter_grocery/helper/api_checker_helper.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:provider/provider.dart';

// class SplashProvider extends ChangeNotifier {
//   final SplashRepo? splashRepo;
//   SplashProvider({required this.splashRepo});

//   ConfigModel? _configModel;
//   BaseUrls? _baseUrls;
//   int _pageIndex = 0;
//   bool _fromSetting = false;
//   bool _firstTimeConnectionCheck = true;
//   bool _cookiesShow = true;
//   List<OfflinePaymentModel?>? _offlinePaymentModelList;

//   ConfigModel? get configModel => _configModel;
//   BaseUrls? get baseUrls => _baseUrls;
//   int get pageIndex => _pageIndex;
//   bool get fromSetting => _fromSetting;
//   bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;
//   bool get cookiesShow => _cookiesShow;
//   List<OfflinePaymentModel?>? get offlinePaymentModelList =>
//       _offlinePaymentModelList;

//   Future<bool> initConfig() async {
//     if (splashRepo == null) return false; // Ensure splashRepo is not null

//     ApiResponseModel apiResponse = await splashRepo!.getConfig();
//     bool isSuccess;

//     if (apiResponse.response != null &&
//         apiResponse.response!.statusCode == 200) {
//       _configModel = ConfigModel.fromJson(apiResponse.response!.data);
//       _baseUrls = _configModel?.baseUrls;
//       isSuccess = true;

//       if (Get.context != null) {
//         final authProvider =
//             Provider.of<AuthProvider>(Get.context!, listen: false);

//         if (authProvider.getGuestId() == null && !authProvider.isLoggedIn()) {
//           authProvider.addOrUpdateGuest();
//         }
//       }

//       if (!kIsWeb && Get.context != null) {
//         final authProvider =
//             Provider.of<AuthProvider>(Get.context!, listen: false);
//         if (!authProvider.isLoggedIn()) {
//           await authProvider.updateFirebaseToken();
//         }
//       }

//       notifyListeners();
//     } else {
//       isSuccess = false;
//       showCustomSnackBarHelper(apiResponse.error.toString(), isError: true);
//     }

//     return isSuccess;
//   }

//   Future<void> initSharedData() async {
//     if (splashRepo != null) {
//       await splashRepo!.initSharedData();
//     }
//   }

//   Future<void> removeSharedData() async {
//     if (splashRepo != null) {
//       await splashRepo!.removeSharedData();
//     }
//   }

//   bool showIntro() {
//     return splashRepo?.showIntro() ?? false; // Use null-aware operator
//   }

//   void disableIntro() {
//     splashRepo?.disableIntro(); // Use null-aware operator
//   }

//   void cookiesStatusChange(String? data) {
//     if (data != null && splashRepo != null) {
//       splashRepo!.sharedPreferences!
//           .setString(AppConstants.cookingManagement, data);
//       _cookiesShow = false;
//       notifyListeners();
//     }
//   }

//   bool getAcceptCookiesStatus(String? data) {
//     return splashRepo?.sharedPreferences
//             ?.getString(AppConstants.cookingManagement) ==
//         data;
//   }

//   Future<void> getOfflinePaymentMethod(bool isReload) async {
//     if (_offlinePaymentModelList == null || isReload) {
//       _offlinePaymentModelList = null;
//     }
//     if (_offlinePaymentModelList == null && splashRepo != null) {
//       ApiResponseModel apiResponse =
//           await splashRepo!.getOfflinePaymentMethod();
//       if (apiResponse.response != null &&
//           apiResponse.response!.statusCode == 200) {
//         _offlinePaymentModelList = [];
//         for (var v in apiResponse.response?.data ?? []) {
//           _offlinePaymentModelList?.add(OfflinePaymentModel.fromJson(v));
//         }
//       } else {
//         ApiCheckerHelper.checkApi(apiResponse);
//       }
//       notifyListeners();
//     }
//   }

//   // Keep setPageIndex unchanged as requested
//   void setPageIndex(int index) {
//     _pageIndex = index;
//     notifyListeners();
//   }
// }
// class SplashProvider extends ChangeNotifier {
//   final SplashRepo? splashRepo;
//   SplashProvider({required this.splashRepo});
//   // bool _hasDataLoaded = false;
//   // bool get hasDataLoaded => _hasDataLoaded;
//   bool _isConfigLoaded = false;
//   bool get isConfigLoaded => _isConfigLoaded;
//   ConfigModel? _configModel;
//   bool _isLoading = false;
//   BaseUrls? _baseUrls;
//   int _pageIndex = 0;
//   bool _fromSetting = false;
//   bool _firstTimeConnectionCheck = true;
//   bool _cookiesShow = true;

//   List<OfflinePaymentModel?>? _offlinePaymentModelList;

//   ConfigModel? get configModel => _configModel;
//   bool get isLoading => _isLoading;
//   BaseUrls? get baseUrls => _baseUrls;
//   int get pageIndex => _pageIndex;
//   bool get fromSetting => _fromSetting;
//   bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;
//   bool get cookiesShow => _cookiesShow;

//   List<OfflinePaymentModel?>? get offlinePaymentModelList =>
//       _offlinePaymentModelList;
//   Future<bool> initConfig() async {
//     _isLoading = true; // Start loading
//     notifyListeners();

//     bool isSuccess = false;
//     try {
//       ApiResponseModel apiResponse = await splashRepo!.getConfig();
//       if (apiResponse.response != null &&
//           apiResponse.response!.statusCode == 200) {
//         // Initialize config model and base URLs
//         _configModel = ConfigModel.fromJson(apiResponse.response!.data);
//         _baseUrls = _configModel?.baseUrls;
//         isSuccess = true;
//         _isConfigLoaded = true;
//         // Handle guest ID and Firebase token if needed
//         if (Get.context != null) {
//           final authProvider =
//               Provider.of<AuthProvider>(Get.context!, listen: false);

//           // Add or update guest if not logged in and no guest ID
//           if (authProvider.getGuestId() == null && !authProvider.isLoggedIn()) {
//             authProvider.addOrUpdateGuest();
//           }
//           //  _hasDataLoaded = true;
//         }

//         // Update Firebase token if not on the web and not logged in
//         if (!kIsWeb) {
//           final authProvider =
//               Provider.of<AuthProvider>(Get.context!, listen: false);
//           if (!authProvider.isLoggedIn()) {
//             await authProvider.updateFirebaseToken();
//           }
//         }
//       } else {
//         // Show error if response failed
//         showCustomSnackBarHelper(apiResponse.error.toString(), isError: true);
//       }
//     } catch (e) {
//       print("Error in initConfig: $e");
//       showCustomSnackBarHelper("Failed to load configuration.", isError: true);
//     }

//     _isLoading = false; // End loading
//     notifyListeners();
//     return isSuccess;
//   }
//   // Future<bool> initConfig() async {
//   //   _isLoading = true; // Set isLoading to true at start
//   //   notifyListeners();

//   //   ApiResponseModel apiResponse = await splashRepo!.getConfig();
//   //   bool isSuccess;
//   //   if (apiResponse.response != null &&
//   //       apiResponse.response!.statusCode == 200) {
//   //     _configModel = ConfigModel.fromJson(apiResponse.response!.data);
//   //     _baseUrls = ConfigModel.fromJson(apiResponse.response!.data).baseUrls;
//   //     isSuccess = true;

//   //     if (Get.context != null) {
//   //       final AuthProvider authProvider =
//   //           Provider.of<AuthProvider>(Get.context!, listen: false);

//   //       if (authProvider.getGuestId() == null && !authProvider.isLoggedIn()) {
//   //         authProvider.addOrUpdateGuest();
//   //       }
//   //     }

//   //     if (!kIsWeb) {
//   //       if (!Provider.of<AuthProvider>(Get.context!, listen: false)
//   //           .isLoggedIn()) {
//   //         await Provider.of<AuthProvider>(Get.context!, listen: false)
//   //             .updateFirebaseToken();
//   //       }
//   //     }
//   //   } else {
//   //     isSuccess = false;
//   //     showCustomSnackBarHelper(apiResponse.error.toString(), isError: true);
//   //   }

//   //   _isLoading = false; // Set isLoading to false after completion
//   //   notifyListeners();
//   //   return isSuccess;
//   // }

//   void setFirstTimeConnectionCheck(bool isChecked) {
//     _firstTimeConnectionCheck = isChecked;
//   }

//   void setPageIndex(int index) {
//     _pageIndex = index;
//     notifyListeners();
//   }

//   Future<bool> initSharedData() {
//     return splashRepo!.initSharedData();
//   }

//   Future<bool> removeSharedData() {
//     return splashRepo!.removeSharedData();
//   }

//   void setFromSetting(bool isSetting) {
//     _fromSetting = isSetting;
//   }

//   String? getLanguageCode() {
//     return splashRepo!.sharedPreferences!.getString(AppConstants.languageCode);
//   }

//   bool showIntro() {
//     return splashRepo!.showIntro();
//   }

//   void disableIntro() {
//     splashRepo!.disableIntro();
//   }

//   void cookiesStatusChange(String? data) {
//     if (data != null) {
//       splashRepo!.sharedPreferences!
//           .setString(AppConstants.cookingManagement, data);
//     }
//     _cookiesShow = false;
//     notifyListeners();
//   }

//   bool getAcceptCookiesStatus(String? data) =>
//       splashRepo!.sharedPreferences!
//               .getString(AppConstants.cookingManagement) !=
//           null &&
//       splashRepo!.sharedPreferences!
//               .getString(AppConstants.cookingManagement) ==
//           data;

//   Future<void> getOfflinePaymentMethod(bool isReload) async {
//     if (_offlinePaymentModelList == null || isReload) {
//       _offlinePaymentModelList = null;
//     }

//     if (_offlinePaymentModelList == null) {
//       _isLoading = true; // Set isLoading to true before fetching data
//       notifyListeners();

//       ApiResponseModel apiResponse =
//           await splashRepo!.getOfflinePaymentMethod();
//       if (apiResponse.response != null &&
//           apiResponse.response!.statusCode == 200) {
//         _offlinePaymentModelList = [];

//         apiResponse.response?.data.forEach((v) {
//           _offlinePaymentModelList?.add(OfflinePaymentModel.fromJson(v));
//         });
//       } else {
//         ApiCheckerHelper.checkApi(apiResponse);
//       }

//       _isLoading = false; // Set isLoading to false after data is fetched
//       notifyListeners();
//     }
//   }
// }

class SplashProvider extends ChangeNotifier {
  final SplashRepo? splashRepo;
  SplashProvider({required this.splashRepo});

  ConfigModel? _configModel;
  BaseUrls? _baseUrls;
  int _pageIndex = 0;
  bool _fromSetting = false;
  bool _firstTimeConnectionCheck = true;
  bool _cookiesShow = true;
  List<OfflinePaymentModel?>? _offlinePaymentModelList;

  ConfigModel? get configModel => _configModel;
  BaseUrls? get baseUrls => _baseUrls;
  int get pageIndex => _pageIndex;
  bool get fromSetting => _fromSetting;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;
  bool get cookiesShow => _cookiesShow;
  List<OfflinePaymentModel?>? get offlinePaymentModelList =>
      _offlinePaymentModelList;

  Future<bool> initConfig() async {
    ApiResponseModel apiResponse = await splashRepo!.getConfig();
    bool isSuccess;
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _configModel = ConfigModel.fromJson(apiResponse.response!.data);
      _baseUrls = ConfigModel.fromJson(apiResponse.response!.data).baseUrls;
      isSuccess = true;

      if (Get.context != null) {
        final AuthProvider authProvider =
            Provider.of<AuthProvider>(Get.context!, listen: false);

        if (authProvider.getGuestId() == null && !authProvider.isLoggedIn()) {
          authProvider.addOrUpdateGuest();
        }
      }

      if (!kIsWeb) {
        if (!Provider.of<AuthProvider>(Get.context!, listen: false)
            .isLoggedIn()) {
          await Provider.of<AuthProvider>(Get.context!, listen: false)
              .updateFirebaseToken();
        }
      }

      notifyListeners();
    } else {
      isSuccess = false;
      showCustomSnackBarHelper(apiResponse.error.toString(), isError: true);
    }
    return isSuccess;
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  void setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }

  Future<bool> initSharedData() {
    return splashRepo!.initSharedData();
  }

  Future<bool> removeSharedData() {
    return splashRepo!.removeSharedData();
  }

  void setFromSetting(bool isSetting) {
    _fromSetting = isSetting;
  }

  String? getLanguageCode() {
    return splashRepo!.sharedPreferences!.getString(AppConstants.languageCode);
  }

  bool showIntro() {
    return splashRepo!.showIntro();
  }

  void disableIntro() {
    splashRepo!.disableIntro();
  }

  void cookiesStatusChange(String? data) {
    if (data != null) {
      splashRepo!.sharedPreferences!
          .setString(AppConstants.cookingManagement, data);
    }
    _cookiesShow = false;
    notifyListeners();
  }

  bool getAcceptCookiesStatus(String? data) =>
      splashRepo!.sharedPreferences!
              .getString(AppConstants.cookingManagement) !=
          null &&
      splashRepo!.sharedPreferences!
              .getString(AppConstants.cookingManagement) ==
          data;

  Future<void> getOfflinePaymentMethod(bool isReload) async {
    if (_offlinePaymentModelList == null || isReload) {
      _offlinePaymentModelList = null;
    }
    if (_offlinePaymentModelList == null) {
      ApiResponseModel apiResponse =
          await splashRepo!.getOfflinePaymentMethod();
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        _offlinePaymentModelList = [];

        apiResponse.response?.data.forEach((v) {
          _offlinePaymentModelList?.add(OfflinePaymentModel.fromJson(v));
        });
      } else {
        ApiCheckerHelper.checkApi(apiResponse);
      }
      notifyListeners();
    }
  }
}
