import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_grocery/features/auth/screens/login_menu_screen.dart';
import 'package:flutter_grocery/features/auth/screens/login_screen.dart';
import 'package:geolocator/geolocator.dart';

import 'package:provider/provider.dart';

import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/features/onboarding/screens/on_boarding_screen.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late StreamSubscription<ConnectivityResult> _onConnectivityChanged;
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    bool firstTime = true;

    // Connectivity listener
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (!firstTime) {
        _handleConnectivityChange(result);
      }
      firstTime = false;
    });

    // Initialize providers and navigate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SplashProvider>(context, listen: false).initSharedData();
      Provider.of<CartProvider>(context, listen: false).getCartData();
    });
    // Provider.of<SplashProvider>(context, listen: false).initSharedData();
    // Provider.of<CartProvider>(context, listen: false).getCartData();

    // Show the GIF for 3 seconds and then navigate
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _animationCompleted = true;
      });
      _route(); // Navigate after 3 seconds
    });
  }

  // Request location permission and handle it
  Future<void> _requestLocationPermission() async {
    try {
      Position position = await _determinePosition();
      // Handle the position if the permission is granted
      print("Location permission granted, position: $position");
    } catch (e) {
      // Handle errors, like denied permission or disabled services
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission required: $e')),
      );
    }
  }

  // Function to determine the device's location
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    bool isNotConnected = result != ConnectivityResult.wifi &&
        result != ConnectivityResult.mobile;

    if (isNotConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          duration: Duration(seconds: 6000),
          content: Text(
            'No connection',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          content: Text(
            'Connected',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  void _route() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Wrap _route in a post-frame callback
      final SplashProvider splashProvider =
          Provider.of<SplashProvider>(context, listen: false);
      splashProvider.initConfig().then((bool isSuccess) {
        if (isSuccess) {
          Timer(const Duration(seconds: 1), () async {
            double minimumVersion = Platform.isAndroid
                ? splashProvider.configModel?.playStoreConfig?.minVersion ??
                    AppConstants.appVersion
                : splashProvider.configModel?.appStoreConfig?.minVersion ??
                    AppConstants.appVersion;
            if (AppConstants.appVersion < minimumVersion &&
                !ResponsiveHelper.isWeb()) {
              Navigator.pushNamedAndRemoveUntil(
                  context, RouteHelper.getUpdateRoute(), (route) => false);
            } else {
              if (Provider.of<AuthProvider>(context, listen: false)
                  .isLoggedIn()) {
                Provider.of<AuthProvider>(context, listen: false).updateToken();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteHelper.menu, (route) => false);
              } else {
                if (splashProvider.showIntro()) {
                  Navigator.of(context).pushReplacementNamed(RouteHelper.login,
                      arguments: const LoginMenuScreen());
                  // Navigator.pushNamedAndRemoveUntil(
                  //     context, RouteHelper.onBoarding, (route) => false,
                  //     arguments: OnBoardingScreen());
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      RouteHelper.menu, (route) => false);
                }
              }
            }
          });
        }
      });
    });
  }
  // void _route() {
  //   final SplashProvider splashProvider =
  //       Provider.of<SplashProvider>(context, listen: false);
  //   splashProvider.initConfig().then((bool isSuccess) {
  //     if (isSuccess) {
  //       Timer(const Duration(seconds: 1), () async {
  //         double minimumVersion = Platform.isAndroid
  //             ? splashProvider.configModel?.playStoreConfig?.minVersion ??
  //                 AppConstants.appVersion
  //             : splashProvider.configModel?.appStoreConfig?.minVersion ??
  //                 AppConstants.appVersion;
  //         if (AppConstants.appVersion < minimumVersion &&
  //             !ResponsiveHelper.isWeb()) {
  //           Navigator.pushNamedAndRemoveUntil(
  //               context, RouteHelper.getUpdateRoute(), (route) => false);
  //         } else {
  //           if (Provider.of<AuthProvider>(context, listen: false)
  //               .isLoggedIn()) {
  //             Provider.of<AuthProvider>(context, listen: false).updateToken();
  //             Navigator.of(context)
  //                 .pushNamedAndRemoveUntil(RouteHelper.menu, (route) => false);
  //           } else {
  //             if (Provider.of<SplashProvider>(context, listen: false)
  //                 .showIntro()) {
  //               Navigator.pushNamedAndRemoveUntil(
  //                   context, RouteHelper.onBoarding, (route) => false,
  //                   arguments: OnBoardingScreen());
  //             } else {
  //               Navigator.of(context).pushNamedAndRemoveUntil(
  //                   RouteHelper.menu, (route) => false);
  //             }
  //           }
  //         }
  //       });
  //     }
  //   });
  // }

  @override
  void dispose() {
    _onConnectivityChanged.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: // _animationCompleted
              //? const SizedBox() // Hide the GIF after 3 seconds
              //:
              SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.6, // Adjust the width as a percentage of the screen width
                  height: MediaQuery.of(context).size.height *
                      0.6, // Adjust the height as a percentage of the screen height
                  child: Image.asset("assets/image/Keakado_Logo_GIF.gif")
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scaleXY(end: 1.2, duration: 1.seconds)
                      .then()
                  // .shake(duration: 1.seconds),
                  )),
    );
  }
}

// import 'dart:async';
// import 'dart:io';
// import 'package:connectivity/connectivity.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_grocery/helper/responsive_helper.dart';
// import 'package:flutter_grocery/localization/app_localization.dart';
// import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
// import 'package:flutter_grocery/common/providers/cart_provider.dart';
// import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
// import 'package:flutter_grocery/helper/route_helper.dart';
// import 'package:flutter_grocery/utill/app_constants.dart';
// import 'package:flutter_grocery/utill/dimensions.dart';
// import 'package:flutter_grocery/utill/images.dart';
// import 'package:flutter_grocery/utill/styles.dart';
// import 'package:flutter_grocery/features/onboarding/screens/on_boarding_screen.dart';
// import 'package:provider/provider.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   late StreamSubscription<ConnectivityResult> _onConnectivityChanged;

//   @override
//   void dispose() {
//     super.dispose();

//     _onConnectivityChanged.cancel();
//   }

//   @override
//   void initState() {
//     super.initState();

//     bool firstTime = true;
//     _onConnectivityChanged = Connectivity()
//         .onConnectivityChanged
//         .listen((ConnectivityResult result) {
//       if (!firstTime) {
//         bool isNotConnected = result != ConnectivityResult.wifi &&
//             result != ConnectivityResult.mobile;
//         isNotConnected
//             ? const SizedBox()
//             : ScaffoldMessenger.of(context).hideCurrentSnackBar();
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           backgroundColor: isNotConnected ? Colors.red : Colors.green,
//           duration: Duration(seconds: isNotConnected ? 6000 : 3),
//           content: Text(
//             isNotConnected ? 'no_connection'.tr : 'connected'.tr,
//             textAlign: TextAlign.center,
//           ),
//         ));
//         if (!isNotConnected) {
//           _route();
//         }
//       }
//       firstTime = false;
//     });

//     Provider.of<SplashProvider>(context, listen: false).initSharedData();
//     Provider.of<CartProvider>(context, listen: false).getCartData();
//     _route();
//   }

//   void _route() {
//     final SplashProvider splashProvider =
//         Provider.of<SplashProvider>(context, listen: false);
//     // Provider.of<SplashProvider>(context, listen: false).removeSharedData();
//     splashProvider.initConfig().then((bool isSuccess) {
//       if (isSuccess) {
//         Timer(const Duration(seconds: 1), () async {
//           double minimumVersion = 0.0;
//           if (Platform.isAndroid) {
//             if (splashProvider.configModel?.playStoreConfig?.minVersion !=
//                 null) {
//               minimumVersion =
//                   splashProvider.configModel?.playStoreConfig?.minVersion ??
//                       AppConstants.appVersion;
//             }
//           } else if (Platform.isIOS) {
//             if (splashProvider.configModel?.appStoreConfig?.minVersion !=
//                 null) {
//               minimumVersion =
//                   splashProvider.configModel?.appStoreConfig?.minVersion ??
//                       AppConstants.appVersion;
//             }
//           }
//           if (AppConstants.appVersion < minimumVersion &&
//               !ResponsiveHelper.isWeb()) {
//             Navigator.pushNamedAndRemoveUntil(
//                 context, RouteHelper.getUpdateRoute(), (route) => false);
//           } else {
//             if (Provider.of<AuthProvider>(context, listen: false)
//                 .isLoggedIn()) {
//               Provider.of<AuthProvider>(context, listen: false).updateToken();
//               Navigator.of(context)
//                   .pushNamedAndRemoveUntil(RouteHelper.menu, (route) => false);
//             } else {
//               if (Provider.of<SplashProvider>(context, listen: false)
//                   .showIntro()) {
//                 Navigator.pushNamedAndRemoveUntil(
//                     context, RouteHelper.onBoarding, (route) => false,
//                     arguments: OnBoardingScreen());
//               } else {
//                 Navigator.of(context).pushNamedAndRemoveUntil(
//                     RouteHelper.menu, (route) => false);
//               }
//             }
//           }
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // SizedBox(
//           //   height: 130,
//           //   width: 130,
//           //   child: ClipRRect(
//           //     borderRadius: BorderRadius.circular(30),
//           //     child: Image.asset(
//           //       Images.appLogo,
//           //       height: 130,
//           //       width: 130,
//           //       // fit: BoxFit.cover,
//           //     ),
//           //   ),
//           // ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 200,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(30),
//                   image: const DecorationImage(
//                     image: AssetImage(Images.appLogo),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: Dimensions.paddingSizeSmall),
//           Text(AppConstants.appName,
//               textAlign: TextAlign.center,
//               style: poppinsMedium.copyWith(
//                 color: Theme.of(context).primaryColor,
//                 fontSize: 30,
//               )),
//         ],
//       ),
//     );
//   }
// }
