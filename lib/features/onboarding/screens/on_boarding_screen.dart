import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_pop_scope_widget.dart';
import 'package:flutter_grocery/features/auth/screens/login_menu_screen.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/onboarding/providers/onboarding_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/features/auth/screens/login_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class OnBoardingScreen extends StatelessWidget {
  final PageController _pageController = PageController();

  OnBoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<OnBoardingProvider>(context, listen: false)
        .getBoardingList(context);

    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<OnBoardingProvider>(
          builder: (context, onBoarding, child) {
            return onBoarding.onBoardingList.isNotEmpty
                ? Stack(
                    children: [
                      // Full-screen image using PageView

                      PageView.builder(
                        itemCount: 1,
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: FittedBox(
                              fit: BoxFit
                                  .cover, // Ensures the image scales correctly
                              child: Image.asset(
                                onBoarding.onboardingLocalList[index],
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Text('Image not found'),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        onPageChanged: (index) =>
                            onBoarding.setSelectIndex(index),
                      ),

                      // Back Button over the Image
                      if (Navigator.of(context).canPop())
                        Positioned(
                          left: 24,
                          top: 64,
                          child: SvgPicture.asset("assets/svg/back_arrow.svg"),
                        ),

                      // Message over the image
                      // const Positioned(
                      //   left: 24,
                      //   top: 124,
                      //   child: Text(
                      //     'Enjoy quick\nand reliable delivery\nservice',
                      //     style: TextStyle(
                      //       color: Colors.white,
                      //       fontSize: 36,
                      //       fontWeight: FontWeight.w600,
                      //       height: 1.25,
                      //     ),
                      //   ),
                      // ),

                      // Button positioned over the image
                      Positioned(
                        bottom: 80,
                        left: 20,
                        right: 20,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: InkWell(
                            onTap: () {
                              // if (onBoarding.selectedIndex ==
                              //     onBoarding.onBoardingList.length - 1) {
                              Provider.of<SplashProvider>(context,
                                      listen: false)
                                  .disableIntro();
                              Navigator.of(context).pushReplacementNamed(
                                  RouteHelper.login,
                                  arguments: const LoginMenuScreen());
                              // } else {
                              //   _pageController.nextPage(
                              //       duration: const Duration(milliseconds: 500),
                              //       curve: Curves.easeIn);
                              // }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 60,
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).primaryColor,
                              ),
                              child: Text(
                                getTranslated("next", context),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Skip Button position over the image
                      Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: InkWell(
                            onTap: () {
                              Provider.of<SplashProvider>(context,
                                      listen: false)
                                  .disableIntro();
                              Navigator.of(context).pushReplacementNamed(
                                  RouteHelper.login,
                                  arguments: const LoginMenuScreen());
                            },
                            child: const Text(
                              "Skip",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox();
          },
        ),
      ),
    );
  }
}
