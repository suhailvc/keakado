import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class PaymentButtonWidget extends StatelessWidget {
  final String icon;
  final String title;
  final bool isSelected;
  final Function onTap;

  const PaymentButtonWidget({
    Key? key,
    required this.isSelected,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (ctx, orderController, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap as void Function()?,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset('assets/svg/cod.svg'),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          title,
                          style: poppinsMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    Radio(
                      value: isSelected,
                      groupValue: true,
                      onChanged: (value) {
                        onTap();
                      },
                      fillColor: WidgetStatePropertyAll(
                        Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
