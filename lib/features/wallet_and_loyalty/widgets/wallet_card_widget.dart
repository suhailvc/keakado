import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/profile/providers/profile_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_directionality_widget.dart';
import 'package:flutter_grocery/features/wallet_and_loyalty/widgets/add_fund_dialogue_widget.dart';
import 'package:provider/provider.dart';

class WalletCardWidget extends StatelessWidget {
  const WalletCardWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel =
        Provider.of<SplashProvider>(context, listen: false).configModel!;

    return Align(
      alignment: Alignment.center,
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // const SizedBox(
                    //     height: Dimensions.paddingSizeExtraLarge),
                    // Image.asset(Images.walletIcon,
                    //     width: Dimensions.paddingSizeLarge),
                    // const SizedBox(height: Dimensions.paddingSizeSmall),
                    CustomDirectionalityWidget(
                        child: Text(
                      PriceConverterHelper.convertPrice(context,
                          profileProvider.userInfoModel?.walletBalance ?? 0),
                      style: poppinsBold.copyWith(
                        fontSize: Dimensions.fontSizeMaxLarge,
                        color: Theme.of(context).primaryColor,
                      ),
                    )),
                    // Text(
                    //   getTranslated('wallet_amount', context),
                    //   style: poppinsRegular.copyWith(
                    //     fontSize: Dimensions.fontSizeDefault,
                    //     color: Colors.white,
                    //   ),
                    // ),
                    // const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraLarge),
              if (configModel.isAddFundToWallet!)
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => const AddFundDialogueWidget());
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: Text(
                    getTranslated("add_fund", context),
                    style: poppinsSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Colors.white,
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
