import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_pop_scope_widget.dart';
import 'package:flutter_grocery/features/menu/domain/models/custom_drawer_controller_model.dart';
import 'package:flutter_grocery/common/enums/html_type_enum.dart';
import 'package:flutter_grocery/features/menu/domain/models/main_screen_model.dart';
import 'package:flutter_grocery/features/notification/providers/notification_provider.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/third_party_chat_widget.dart';
import 'package:flutter_grocery/features/address/screens/address_list_screen.dart';
import 'package:flutter_grocery/features/cart/screens/cart_screen.dart';
import 'package:flutter_grocery/features/category/screens/all_categories_screen.dart';
import 'package:flutter_grocery/features/chat/screens/chat_screen.dart';
import 'package:flutter_grocery/features/coupon/screens/coupon_screen.dart';
import 'package:flutter_grocery/features/home/screens/home_screens.dart';
import 'package:flutter_grocery/features/html/screens/html_viewer_screen.dart';
import 'package:flutter_grocery/features/wallet_and_loyalty/screens/loyalty_screen.dart';
import 'package:flutter_grocery/features/order/screens/order_list_screen.dart';
import 'package:flutter_grocery/features/order/screens/order_search_screen.dart';
import 'package:flutter_grocery/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:flutter_grocery/features/menu/screens/setting_screen.dart';
import 'package:flutter_grocery/features/wallet_and_loyalty/screens/wallet_screen.dart';
import 'package:flutter_grocery/features/wishlist/screens/wishlist_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

List<MainScreenModel> screenList = [
  MainScreenModel(const HomeScreen(), 'home', Images.home),
  MainScreenModel(const AllCategoriesScreen(), 'all_categories', Images.list),
  MainScreenModel(const CartScreen(), 'shopping_bag', Images.orderBag),
  MainScreenModel(const WishListScreen(), 'favourite', Images.favouriteIcon),
  MainScreenModel(const OrderListScreen(), 'my_order', Images.orderList),
  MainScreenModel(
      const OrderSearchScreen(), 'track_order', Images.orderDetails),
  MainScreenModel(const AddressListScreen(), 'address', Images.location),
  MainScreenModel(const CouponScreen(), 'coupon', Images.coupon),
  MainScreenModel(
      const ChatScreen(
        orderModel: null,
      ),
      'live_chat',
      Images.chat),
  MainScreenModel(const SettingsScreen(), 'settings', Images.settings),
  if (Provider.of<SplashProvider>(Get.context!, listen: false)
      .configModel!
      .walletStatus!)
    MainScreenModel(const WalletScreen(), 'wallet', Images.wallet),
  if (Provider.of<SplashProvider>(Get.context!, listen: false)
      .configModel!
      .loyaltyPointStatus!)
    MainScreenModel(const LoyaltyScreen(), 'loyalty_point', Images.loyaltyIcon),
  MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.termsAndCondition),
      'terms_and_condition', Images.termsAndConditions),
  MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.privacyPolicy),
      'privacy_policy', Images.privacyPolicy),
  MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.aboutUs),
      'about_us', Images.aboutUs),
  if (Provider.of<SplashProvider>(Get.context!, listen: false)
      .configModel!
      .returnPolicyStatus!)
    MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.returnPolicy),
        'return_policy', Images.returnPolicy),
  if (Provider.of<SplashProvider>(Get.context!, listen: false)
      .configModel!
      .refundPolicyStatus!)
    MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.refundPolicy),
        'refund_policy', Images.refundPolicy),
  if (Provider.of<SplashProvider>(Get.context!, listen: false)
      .configModel!
      .cancellationPolicyStatus!)
    MainScreenModel(
        const HtmlViewerScreen(htmlType: HtmlType.cancellationPolicy),
        'cancellation_policy',
        Images.cancellationPolicy),
  MainScreenModel(
      const HtmlViewerScreen(htmlType: HtmlType.faq), 'faq', Images.faq),
];

class MainScreen extends StatefulWidget {
  final bool isReload;
  final CustomDrawerController? drawerController;
  const MainScreen({Key? key, this.drawerController, this.isReload = true})
      : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool canExit = kIsWeb;

  @override
  void initState() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    Provider.of<NotificationProvider>(context, listen: false)
        .getNotificationList();
    locationProvider.getCurrentLocation(context, true);
    if (widget.isReload) {
      HomeScreen.loadData(true, Get.context!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final bool isDarkTheme =
    //     Provider.of<ThemeProvider>(context, listen: false).darkTheme;
    return Consumer<SplashProvider>(
      builder: (context, splash, child) {
        return CustomPopScopeWidget(
          child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
            final referMenu = MainScreenModel(const ReferAndEarnScreen(),
                'referAndEarn', Images.referralIcon);
            if ((splash.configModel?.referEarnStatus ?? false) &&
                profileProvider.userInfoModel?.referCode != null &&
                screenList[9].title != 'referAndEarn') {
              screenList.removeWhere((menu) => menu.screen == referMenu.screen);
              screenList.insert(9, referMenu);
            }

            return Consumer<LocationProvider>(
              builder: (context, locationProvider, child) => InkWell(
                onTap: () {
                  if (!ResponsiveHelper.isDesktop(context) &&
                      widget.drawerController!.isOpen()) {
                    //  widget.drawerController.toggle();
                  }
                },
                child: Scaffold(
                  floatingActionButton: !ResponsiveHelper.isDesktop(context)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50.0),
                          child: ThirdPartyChatWidget(
                            configModel: splash.configModel!,
                          ),
                        )
                      : null,
                  appBar: ResponsiveHelper.isDesktop(context)
                      ? null
                      : AppBar(
                          scrolledUnderElevation: 0,
                          backgroundColor: Theme.of(context).cardColor,
                          // leading: SizedBox(
                          //   width: 0,
                          // ),
                          // leading: IconButton(
                          //     icon: Image.asset(Images.moreIcon,
                          //         color: Theme.of(context).primaryColor,
                          //         height: 30,
                          //         width: 30),
                          //     onPressed: () {
                          //       // widget.drawerController.toggle();
                          //     }),
                          // title: splash.pageIndex == 0
                          //     ? Row(children: [
                          //         Image.asset(Images.appLogo, width: 25),
                          //         const SizedBox(
                          //             width: Dimensions.paddingSizeSmall),
                          //         Expanded(
                          //             child: Text(
                          //           AppConstants.appName,
                          //           maxLines: 1,
                          //           overflow: TextOverflow.ellipsis,
                          //           style: poppinsMedium.copyWith(
                          //               color: Theme.of(context).primaryColor),
                          //         )),
                          //       ])
                          //     : Text(
                          title: splash.pageIndex == 0
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                "assets/svg/location.svg",
                                                height: 20,
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              const Text(
                                                'Deliver to',
                                                style: TextStyle(
                                                  color: Color(0xFF133051),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: -0.50,
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            (locationProvider.address ??
                                                        'Fetching location...')
                                                    .substring(
                                                        0,
                                                        (locationProvider.address ??
                                                                        'Fetching location...')
                                                                    .length >
                                                                31
                                                            ? 31
                                                            : (locationProvider
                                                                        .address ??
                                                                    'Fetching location...')
                                                                .length) +
                                                ((locationProvider.address ??
                                                                'Fetching location...')
                                                            .length >
                                                        31
                                                    ? '...'
                                                    : ''),
                                            style: const TextStyle(
                                              color: Color(0xFF133051),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.50,
                                            ),
                                          ),

                                          // Text(
                                          //   locationProvider.address ??
                                          //       'Fetching location...',
                                          //   //  'Lusail, Marina Twin Tower B',
                                          //   style: const TextStyle(
                                          //     color: Color(0xFF133051),
                                          //     fontSize: 13,
                                          //     fontWeight: FontWeight.w600,
                                          //     letterSpacing: -0.50,
                                          //   ),
                                          // )
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(context,
                                                  RouteHelper.notification)
                                              .then((_) {
                                            // Clear the notification count after opening the notification screen
                                            Provider.of<NotificationProvider>(
                                                    context,
                                                    listen: false)
                                                .clearNewNotificationCount();
                                          });
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: ShapeDecoration(
                                                shape: RoundedRectangleBorder(
                                                  side: const BorderSide(
                                                      width: 1,
                                                      color: Color(0xFFD2F0C9)),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: SvgPicture.asset(
                                                'assets/svg/notification.svg',
                                              ),
                                            ),
                                            // Badge to display notification count
                                            Positioned(
                                              right: 4,
                                              top: 4,
                                              child: Consumer<
                                                  NotificationProvider>(
                                                builder:
                                                    (context, provider, child) {
                                                  int newNotificationCount =
                                                      provider
                                                          .newNotificationCount;
                                                  return newNotificationCount >
                                                          0
                                                      ? CircleAvatar(
                                                          radius: 8,
                                                          backgroundColor:
                                                              Colors.red,
                                                          child: Text(
                                                            newNotificationCount
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox(); // No badge if count is 0
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      )

                                      // GestureDetector(
                                      //   onTap: () {
                                      //     Navigator.pushNamed(context,
                                      //         RouteHelper.notification);
                                      //   },
                                      //   child: Container(
                                      //     width: 40,
                                      //     height: 40,
                                      //     decoration: ShapeDecoration(
                                      //       shape: RoundedRectangleBorder(
                                      //         side: const BorderSide(
                                      //             width: 1,
                                      //             color: Color(0xFFD2F0C9)),
                                      //         borderRadius:
                                      //             BorderRadius.circular(14),
                                      //       ),
                                      //     ),
                                      //     alignment: Alignment.center,
                                      //     child: SvgPicture.asset(
                                      //       'assets/svg/notification.svg',
                                      //     ),
                                      //   ),
                                      // )
                                    ],
                                  ),
                                )
                              : Text(
                                  getTranslated(
                                      screenList[splash.pageIndex].title,
                                      context),
                                  style: poppinsMedium.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).primaryColor),
                                ),
                          actions:
                              //     ? [
                              //         IconButton(
                              //           icon: Image.asset(Images.search,
                              //               color: Theme.of(context).primaryColor,
                              //               width: 25),
                              //           onPressed: () {
                              //             Navigator.pushNamed(
                              //                 context, RouteHelper.searchProduct);
                              //           },
                              //         ),
                              //         IconButton(
                              //             icon: Stack(
                              //                 clipBehavior: Clip.none,
                              //                 children: [
                              //                   Icon(Icons.shopping_cart,
                              //                       color: Theme.of(context)
                              //                           .hintColor
                              //                           .withOpacity(isDarkTheme
                              //                               ? 0.9
                              //                               : 0.4),
                              //                       size: 30),
                              //                   Positioned(
                              //                     top: -7,
                              //                     right: -2,
                              //                     child: Container(
                              //                       padding:
                              //                           const EdgeInsets.all(6),
                              //                       decoration: BoxDecoration(
                              //                           shape: BoxShape.circle,
                              //                           color: Theme.of(context)
                              //                               .primaryColor),
                              //                       child: Text(
                              //                           '${Provider.of<CartProvider>(context).cartList.length}',
                              //                           style: TextStyle(
                              //                               color: Theme.of(context)
                              //                                   .cardColor,
                              //                               fontSize: 10)),
                              //                     ),
                              //                   ),
                              //                 ]),
                              //             onPressed: () {
                              //               splash.setPageIndex(2);
                              //             }),
                              //       ]
                              //     :
                              splash.pageIndex == 2
                                  ? [
                                      Center(child: Consumer<CartProvider>(
                                          builder: (context, cartProvider, _) {
                                        return Text(
                                            '${cartProvider.cartList.length} ${getTranslated('items', context)}',
                                            style: poppinsMedium.copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor));
                                      })),
                                      const SizedBox(width: 20)
                                    ]
                                  : null,
                        ),
                  body: screenList[splash.pageIndex].screen,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
