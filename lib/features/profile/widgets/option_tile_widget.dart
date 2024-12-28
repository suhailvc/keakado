import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/help_and_support/screens/help_and_support.dart';
import 'package:flutter_grocery/features/menu/widgets/currency_dialog_widget.dart';
import 'package:flutter_grocery/features/menu/widgets/delete_dialog_widget.dart';
import 'package:flutter_grocery/features/menu/widgets/sign_out_dialog_widget.dart';
import 'package:flutter_grocery/helper/dialog_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OptionTileWidget extends StatelessWidget {
  final int index;
  const OptionTileWidget({
    Key? key,
    required this.screens,
    required this.index,
  }) : super(key: key);

  final List<Map<String, String>> screens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: index == 0 ? 0 : 12.0),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          switch (screens[index]['icon']) {
            case "profile":
              Navigator.pushNamed(context, RouteHelper.getProfileEditRoute());
              return;
            case "order":
              Navigator.pushNamed(context, RouteHelper.orderListScreen);
              return;
            case "notification":
              Navigator.pushNamed(context, RouteHelper.notification);
              return;
            case "whishlist":
              Navigator.pushNamed(context, RouteHelper.getFavoriteRoute());
              return;
            case "coupon_icon":
              Navigator.pushNamed(context, RouteHelper.coupon);
              return;
            case "location":
              Navigator.pushNamed(context, RouteHelper.address);
              return;
            // case "message_icon":
            //   Navigator.pushNamed(context, RouteHelper.chatScreen);
            //   return;
            case "wallet_icon":
              Navigator.pushNamed(context, RouteHelper.getWalletRoute());
              return;
            case "language":
              showDialogHelper(context, const CurrencyDialogWidget());
              // Navigator.pushNamed(context, RouteHelper.language);
              return;
            case "privacy":
              Navigator.pushNamed(context, RouteHelper.getPolicyRoute());
              return;
            case "terms":
              Navigator.pushNamed(context, RouteHelper.getTermsRoute());
              return;
            case "help":
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpAndSupportScreen(),
                  ));
              return;

            case "logout":
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const SignOutDialogWidget(),
              );
              return;
            case "delete":
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const DeleteDialogWidget(),
              );
              return;
            default:
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEDFFE8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    "assets/svg/${screens[index]['icon']}.svg",
                    height: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  getTranslated(screens[index]['label'], context),
                  style: poppinsSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right)
          ],
        ),
      ),
    );
  }
}
