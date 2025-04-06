// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/cart/screens/cart_screen.dart';
import 'package:flutter_grocery/features/category/screens/all_categories_screen.dart';
import 'package:flutter_grocery/features/menu/domain/models/custom_drawer_controller_model.dart';
import 'package:flutter_grocery/features/menu/screens/main_screen.dart';
import 'package:flutter_grocery/features/offers/screens/offer_screen.dart';
import 'package:flutter_grocery/features/profile/screens/profile_screen.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class BottomBarView extends StatefulWidget {
  const BottomBarView({Key? key, this.navigation}) : super(key: key);
  final String? navigation;

  @override
  State<BottomBarView> createState() => _MaterialBottomBarViewState();
}

class _MaterialBottomBarViewState extends State<BottomBarView> {
  int currentIndex = 0;
  final CustomDrawerController drawerController = CustomDrawerController();

  @override
  void initState() {
    super.initState();
    switch (widget.navigation) {
      case "to_home":
        currentIndex = 0;
        break;
      case "to_categories":
        currentIndex = 1;
        break;
      case "to_offer":
        currentIndex = 2;
        break;
      case "to_cart":
        currentIndex = 3;
        break;
      case "to_profile":
        currentIndex = 4;
        break;
    }
  }

  final List<Widget> pages = [
    const MainScreen(),
    const AllCategoriesScreen(),
    const OfferScreen(),
    const CartScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            currentIndex: currentIndex,
            onTap: (index) async {
              setState(() {
                currentIndex = index;
              });
              //Event called to change bottom navigation index
            },
            items: [
              bottomNavIcons("assets/svg/home-2.svg", "Home", 0),
              bottomNavIcons("assets/svg/category-2.svg", "Categories", 1),
              bottomNavIcons("assets/svg/offers.svg", "Offers", 2),
              bottomNavIcons("assets/svg/shop.svg", "Cart", 3),
              bottomNavIcons("assets/svg/user-square.svg", "My Account", 4),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem bottomNavIcons(
      String iconUrl, String label, int index) {
    return BottomNavigationBarItem(
      icon: label == "Cart"
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    iconUrl,
                    color: Colors.grey,
                  ),
                ),
                Positioned(
                  right: -4,
                  top: -4,
                  child: Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      return cartProvider.cartList.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                cartProvider.cartList.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const SizedBox();
                    },
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                iconUrl,
                color: Colors.grey,
              ),
            ),
      label: getTranslated(label, context),
      activeIcon: label == "Cart"
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    iconUrl,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  right: -4,
                  top: -4,
                  child: Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      return cartProvider.cartList.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                cartProvider.cartList.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : const SizedBox();
                    },
                  ),
                ),
              ],
            )
          : Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                iconUrl,
                color: Colors.white,
              ),
            ),
      // activeIcon: Container(
      //   padding: const EdgeInsets.all(8),
      //   decoration: BoxDecoration(
      //     color: Theme.of(context).primaryColor,
      //     shape: BoxShape.circle,
      //   ),
      //   child: SvgPicture.asset(
      //     iconUrl,
      //     color: Colors.white,
      //   ),
      // ),
    );
  }

  // BottomNavigationBarItem bottomNavIcons(String iconUrl, String label, index) {
  //   return BottomNavigationBarItem(
  //     icon: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: SvgPicture.asset(
  //         iconUrl,
  //         color: Colors.grey,
  //       ),
  //     ),
  //     label: label,
  //     activeIcon: Container(
  //       padding: const EdgeInsets.all(8),
  //       decoration: BoxDecoration(
  //           color: Theme.of(context).primaryColor, shape: BoxShape.circle),
  //       child: SvgPicture.asset(iconUrl, color: Colors.white),
  //     ),
  //   );
  // }
}
