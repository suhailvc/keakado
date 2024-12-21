import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';
import 'package:flutter_grocery/features/coupon/providers/coupon_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/common/widgets/no_data_widget.dart';
import 'package:flutter_grocery/common/widgets/not_login_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/footer_web_widget.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({Key? key}) : super(key: key);

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  @override
  void initState() {
    super.initState();

    final bool isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    final bool isGuestCheckout =
        Provider.of<SplashProvider>(context, listen: false)
                .configModel
                ?.isGuestCheckout ??
            false;

    if (isLoggedIn || isGuestCheckout) {
      Provider.of<CouponProvider>(context, listen: false)
          .getCouponList(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider =
        Provider.of<SplashProvider>(context, listen: false);
    final double width = MediaQuery.of(context).size.width;
    final bool isLoggedIn =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    final bool isGuestCheckout =
        Provider.of<SplashProvider>(context, listen: false)
                .configModel
                ?.isGuestCheckout ??
            false;

    return Scaffold(
      backgroundColor: ColorResources.scaffoldGrey,
      appBar: ResponsiveHelper.isMobilePhone()
          ? AppBar(
              backgroundColor: Theme.of(context).cardColor,
              leading: GestureDetector(
                onTap: () {
                  splashProvider.setPageIndex(0);
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.chevron_left,
                  size: 30,
                ),
              ),
              centerTitle: true,
              title: Text(
                getTranslated('coupon', context),
                style: poppinsSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            )
          : (const PreferredSize(
              preferredSize: Size.fromHeight(120),
              child: WebAppBarWidget())) as PreferredSizeWidget?,
      body: isLoggedIn || isGuestCheckout
          ? Consumer<CouponProvider>(
              builder: (context, couponProvider, child) {
                return couponProvider.couponList == null
                    ? Center(
                        child: CustomLoaderWidget(
                            color: Theme.of(context).primaryColor),
                      )
                    : (couponProvider.couponList?.isNotEmpty ?? false)
                        ? RefreshIndicator(
                            onRefresh: () async {
                              await couponProvider.getCouponList(context);
                            },
                            backgroundColor: Theme.of(context).primaryColor,
                            child: CustomScrollView(slivers: [
                              SliverToBoxAdapter(
                                child: Center(
                                  child: Container(
                                    padding: width > 700
                                        ? const EdgeInsets.all(
                                            Dimensions.paddingSizeLarge)
                                        : EdgeInsets.zero,
                                    child: Container(
                                      width: width > 700 ? 700 : width,
                                      padding: width > 700
                                          ? const EdgeInsets.all(
                                              Dimensions.paddingSizeDefault)
                                          : null,
                                      decoration: width > 700
                                          ? BoxDecoration(
                                              color:
                                                  Theme.of(context).cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Theme.of(context)
                                                        .shadowColor,
                                                    blurRadius: 5,
                                                    spreadRadius: 1)
                                              ],
                                            )
                                          : null,
                                      child: ListView.builder(
                                        itemCount:
                                            couponProvider.couponList?.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeLarge),
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: Dimensions
                                                    .paddingSizeLarge),
                                            child: Stack(
                                              children: [
                                                Image.asset(
                                                  index % 2 == 0
                                                      ? Images.couponBg1
                                                      : Images.couponBg2,
                                                  height: 125,
                                                  width: 1170,
                                                  fit: BoxFit.fill,
                                                  // color: Theme.of(context)
                                                  //     .primaryColor,
                                                ),
                                                Container(
                                                  height: 100,
                                                  alignment: Alignment.center,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 16.0,
                                                                left: 16),
                                                        child: Transform.rotate(
                                                          angle: -90 * pi / 180,
                                                          child: Text(
                                                            couponProvider
                                                                        .couponList![
                                                                            index]
                                                                        .couponType ==
                                                                    'free_delivery'
                                                                ? getTranslated(
                                                                    'free_delivery',
                                                                    context)
                                                                : '${couponProvider.couponList![index].discount}${couponProvider.couponList![index].discountType == 'percent' ? '%' : Provider.of<SplashProvider>(context, listen: false).configModel!.currencySymbol}\nOFF',
                                                            style: poppinsBold
                                                                .copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeOverLarge,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 32,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const SizedBox(
                                                                height: 16),
                                                            SelectableText(
                                                              couponProvider
                                                                  .couponList![
                                                                      index]
                                                                  .title!,
                                                              style: poppinsBold
                                                                  .copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: Dimensions
                                                                    .fontSizeOverLarge,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            Row(
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Clipboard
                                                                        .setData(
                                                                      ClipboardData(
                                                                        text: couponProvider.couponList![index].code ??
                                                                            "",
                                                                      ),
                                                                    );
                                                                    showCustomSnackBarHelper(
                                                                        getTranslated(
                                                                            'coupon_code_copied',
                                                                            context),
                                                                        isError:
                                                                            false);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                          couponProvider.couponList![index].code ??
                                                                              "",
                                                                          style:
                                                                              poppinsSemiBold.copyWith(
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                8),
                                                                        const Icon(
                                                                          Icons
                                                                              .copy,
                                                                          size:
                                                                              20,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const FooterWebWidget(
                                  footerType: FooterType.sliver),
                            ]),
                          )
                        : NoDataWidget(
                            title: getTranslated('coupon_not_found', context));
              },
            )
          : const NotLoggedInWidget(),
    );
  }
}
