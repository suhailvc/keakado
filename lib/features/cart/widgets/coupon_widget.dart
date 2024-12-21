import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/coupon/providers/coupon_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class CouponWidget extends StatelessWidget {
  const CouponWidget({
    Key? key,
    required this.couponController,
    required this.total,
    required this.deliveryCharge,
  }) : super(key: key);

  final TextEditingController couponController;
  final double total;
  final double deliveryCharge;

  @override
  Widget build(BuildContext context) {
    return Consumer<CouponProvider>(builder: (context, couponProvider, child) {
      return Row(children: [
        Expanded(
          child: TextField(
            controller: couponController,
            style: poppinsSemiBold,
            decoration: InputDecoration(
              hintText: getTranslated('enter_promo_code', context),
              hintStyle: poppinsBold.copyWith(
                color: Theme.of(context).hintColor.withOpacity(0.2),
                fontSize: Dimensions.fontSizeSmall,
              ),
              isDense: true,
              filled: true,
              enabled: couponProvider.discount == 0,
              fillColor: ColorResources.scaffoldGrey,
              border: const OutlineInputBorder(
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(15)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            print('FREE ${couponProvider.freeDeliveryCoupon}');
            if (couponController.text.isEmpty) {
              return;
            } else if (couponController.text.isNotEmpty &&
                !couponProvider.isLoading) {
              if (couponProvider.discount! < 1 &&
                  Provider.of<CouponProvider>(context, listen: false)
                          .freeDeliveryCoupon ==
                      false) {
                couponProvider.applyCoupon(
                    couponController.text, (total - deliveryCharge));
              } else {
                couponProvider.removeCouponData(true);
              }
            } else {
              showCustomSnackBarHelper(
                  getTranslated('invalid_code_or_failed', context),
                  isError: true);
            }
          },
          child: (couponProvider.discount! <= 0 &&
                  couponProvider.freeDeliveryCoupon == false)
              ? Container(
                  height: 48,
                  width: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(15),
                    ),
                  ),
                  child: !couponProvider.isLoading
                      ? Text(
                          getTranslated('apply', context),
                          style: poppinsMedium.copyWith(color: Colors.white),
                        )
                      : const Center(
                          child: SizedBox(
                          height: Dimensions.paddingSizeExtraLarge,
                          width: Dimensions.paddingSizeExtraLarge,
                          child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)),
                        )),
                )
              : Icon(Icons.clear, color: Theme.of(context).colorScheme.error),
        )
      ]);
    });
  }
}
