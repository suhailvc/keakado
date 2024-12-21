// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DefaultBottomBar extends StatelessWidget {
  final int index;
  const DefaultBottomBar({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: index,
        onTap: (index) async {
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteHelper.getMainRoute(
                "to_${index == 0 ? "home" : index == 1 ? "categories" : index == 2 ? "offer" : index == 3 ? "cart" : "profile"}"),
            (route) => false,
          );
        },
        items: [
          bottomNavIcons("assets/svg/home-2.svg", "Home", 0, context),
          bottomNavIcons("assets/svg/category-2.svg", "Categories", 1, context),
          bottomNavIcons("assets/svg/offers.svg", "Offers", 2, context),
          bottomNavIcons("assets/svg/shop.svg", "Cart", 3, context),
          bottomNavIcons(
              "assets/svg/user-square.svg", "My Account", 4, context),
        ],
      ),
    );
  }

  BottomNavigationBarItem bottomNavIcons(
      String iconUrl, String label, index, BuildContext context) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset(
          iconUrl,
          color: Colors.grey,
        ),
      ),
      label: label,
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor, shape: BoxShape.circle),
        child: SvgPicture.asset(iconUrl, color: Colors.white),
      ),
    );
  }
}
