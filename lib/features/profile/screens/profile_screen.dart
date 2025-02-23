import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/not_login_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/profile/widgets/option_tile_widget.dart';
import 'package:flutter_grocery/features/profile/widgets/profile_details_widget.dart';
import 'package:flutter_grocery/features/profile/widgets/profile_header_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _isLoggedIn;

  final List<Map<String, String>> screens = [
    {"icon": "profile", "label": "profile"},
    {"icon": "order", "label": "my_orders"},
    {"icon": "notification", "label": "notifications"},
    {"icon": "Refferandearn", "label": "Refer and Earn"},
    {"icon": "whishlist", "label": "Wishlist"},
    {"icon": "coupon_icon", "label": "coupon"},
    {"icon": "location", "label": "address"},
    // {"icon": "message_icon", "label": "Message"},
    {"icon": "wallet_icon", "label": "wallet"},
    {"icon": "language", "label": "language"},
    {"icon": "privacy", "label": "privacy_policy"},
    // {"icon": "terms", "label": "terms_and_condition"},
    {"icon": "help", "label": "Help & Support"},
    {"icon": "logout", "label": "log_out"},
    {"icon": "delete", "label": "delete"}
  ];

  @override
  void initState() {
    super.initState();

    _isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    if (_isLoggedIn) {
      Provider.of<ProfileProvider>(context, listen: false).getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SplashProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: ColorResources.scaffoldGrey,
      appBar: ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(
              preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
          : AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: Theme.of(context).cardColor,
              // leading: IconButton(
              //     icon: Image.asset(Images.moreIcon, color: Theme.of(context).primaryColor),
              //     onPressed: () {
              //       splashProvider.setPageIndex(0);
              //       Navigator.of(context).pop();
              //     }),
              centerTitle: true,
              title: Text(
                getTranslated("profile", context),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
      body: SafeArea(
        child: _isLoggedIn
            ? Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraLarge,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Column(
                          children: [
                            ProfileHeaderWidget(),
                            ProfileDetailsWidget(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: List.generate(
                            screens.length,
                            (index) {
                              //if (screens[index]['label'] != "language") {
                              return OptionTileWidget(
                                screens: screens,
                                index: index,
                              );
                              //  }
                              //return Container(); // Return an empty container for "language"
                            },
                          ),
                        ),
                        // child: Column(
                        //   children: List.generate(
                        //     screens.length,
                        //     (index) => OptionTileWidget(
                        //       screens: screens,
                        //       index: index,
                        //     ),
                        //   ),
                        // ),
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     if (_isLoggedIn) {
                      //       showDialog(
                      //           context: context,
                      //           barrierDismissible: false,
                      //           builder: (context) =>
                      //               const SignOutDialogWidget());
                      //     } else {
                      //       splashProvider.setPageIndex(0);
                      //       Navigator.pushNamedAndRemoveUntil(context,
                      //           RouteHelper.getLoginRoute(), (route) => false);
                      //     }
                      //   },
                      //   child: Text(
                      //     getTranslated(
                      //         _isLoggedIn ? 'log_out' : 'login', context),
                      //   ),
                      // ),
                    ],
                  ),
                );
              })
            : const NotLoggedInWidget(),
      ),
    );
  }
}
