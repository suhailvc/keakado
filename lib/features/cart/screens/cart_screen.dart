import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/enums/footer_type_enum.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/common/widgets/title_widget.dart';
import 'package:flutter_grocery/features/cart/widgets/cart_button_widget.dart';
import 'package:flutter_grocery/features/cart/widgets/cart_product_list_widget.dart';
import 'package:flutter_grocery/features/cart/widgets/related_product_widget.dart';
import 'package:flutter_grocery/features/home/widgets/home_item_widget.dart';
import 'package:flutter_grocery/helper/default_bottom_bar.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/coupon/providers/coupon_provider.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/common/widgets/footer_web_widget.dart';
import 'package:flutter_grocery/common/widgets/no_data_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_grocery/features/auth/providers/auth_provider.dart';

import '../widgets/cart_details_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  late bool _isLoggedIn;
  String? _userToken;
  @override
  void initState() {
    _couponController.clear();
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    Provider.of<ProductProvider>(context, listen: false)
        .getRelatedProduct(authProvider.getUserToken());
    Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
    Provider.of<OrderProvider>(context, listen: false)
        .setOrderType('delivery', notify: false);

    _isLoggedIn = authProvider.isLoggedIn();
    _userToken = authProvider.getUserToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final configModel =
        Provider.of<SplashProvider>(context, listen: false).configModel!;
    final OrderProvider orderProvider =
        Provider.of<OrderProvider>(context, listen: false);

    // bool isSelfPickupActive = configModel.selfPickup == 1;
    bool isSelfPickupActive = false;
    bool kmWiseCharge = configModel.deliveryManagement!.status!;

    return Scaffold(
      backgroundColor: ColorResources.scaffoldGrey,
      appBar: ResponsiveHelper.isMobilePhone()
          ? AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: Theme.of(context).cardColor,
              // leading: GestureDetector(
              //   onTap: () {
              //     splashProvider.setPageIndex(0);
              //     Navigator.of(context).pop();
              //   },
              //   child: const Icon(
              //     Icons.chevron_left,
              //     size: 30,
              //   ),
              // ),
              centerTitle: true,
              title: Text(
                getTranslated("cart", context).toCapitalized(),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            )
          : (ResponsiveHelper.isDesktop(context)
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
              : null) as PreferredSizeWidget?,
      body: Center(
        child: Consumer<CouponProvider>(builder: (context, couponProvider, _) {
          return Consumer<CartProvider>(
            builder: (context, cart, child) {
              double? deliveryCharge = _getDeliveryChange(
                orderProvider.orderType,
                kmWiseCharge,
                configModel.deliveryCharge,
                couponProvider.coupon?.couponType,
              );

              double itemPrice = 0;
              double discount = 0;
              double tax = 0;

              for (var cartModel in cart.cartList) {
                itemPrice =
                    itemPrice + (cartModel.price! * cartModel.quantity!);
                discount =
                    discount + (cartModel.discount! * cartModel.quantity!);
                tax = tax + (cartModel.tax! * cartModel.quantity!);
              }

              double subTotal =
                  itemPrice + (configModel.isVatTexInclude! ? 0 : tax);
              // bool isFreeDelivery =
              //     subTotal >= configModel.freeDeliveryOverAmount! &&
              //             configModel.freeDeliveryStatus! ||
              //         couponProvider.coupon?.couponType == 'free_delivery';

              bool isFreeDelivery = true;

              double total = subTotal -
                  discount -
                  Provider.of<CouponProvider>(context).discount! +
                  // ignore: dead_code
                  (isFreeDelivery ? 0 : deliveryCharge);

              return cart.cartList.isNotEmpty
                  ? !ResponsiveHelper.isDesktop(context)
                      ? Column(children: [
                          Expanded(
                              child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeSmall,
                            ),
                            child: Center(
                                child: SizedBox(
                              width: Dimensions.webScreenWidth,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product
                                    const CartProductListWidget(),
                                    //const SizedBox(height: Dimensions.paddingSizeDefault),

                                    CartDetailsWidget(
                                      couponController: _couponController,
                                      total: total,
                                      isSelfPickupActive: isSelfPickupActive,
                                      kmWiseCharge: kmWiseCharge,
                                      isFreeDelivery: isFreeDelivery,
                                      itemPrice: itemPrice,
                                      tax: tax,
                                      discount: discount,
                                      deliveryCharge: deliveryCharge,
                                    ),
                                    const SizedBox(height: 40),
                                    Consumer<ProductProvider>(builder:
                                        (context, productProvider, child) {
                                      if (productProvider.isLoading) {
                                        return SizedBox(); // You can show a loading widget here if needed
                                      }

                                      // Null check for relatedProductModel and its products list
                                      var relatedProducts = productProvider
                                          .reltedProductModel?.products;

                                      if (relatedProducts == null ||
                                          relatedProducts.isEmpty) {
                                        return SizedBox(); // Return an empty widget if no related products
                                      }
                                      // ignore: prefer_is_empty
                                      return (productProvider
                                                  .reltedProductModel!
                                                  .products!
                                                  .length) !=
                                              0
                                          ? Column(children: [
                                              TitleWidget(
                                                title: getTranslated(
                                                    "Related Products",
                                                    context),
                                              ),
                                              RelatedProductWidget(
                                                  productList: productProvider
                                                      .reltedProductModel
                                                      ?.products),
                                            ])
                                          : SizedBox();
                                    }),
                                  ]),
                            )),
                          )),
                          CartButtonWidget(
                            isLoggedin: _isLoggedIn,
                            itemDiscount: discount,
                            subTotal: subTotal,
                            configModel: configModel,
                            itemPrice: itemPrice,
                            total: total,
                            isFreeDelivery: isFreeDelivery,
                            deliveryCharge: deliveryCharge,
                          ),
                          // if (Navigator.of(context).canPop())
                          //   const DefaultBottomBar(index: 3)
                        ])
                      : CustomScrollView(slivers: [
                          SliverToBoxAdapter(
                            child: Center(
                                child: SizedBox(
                                    width: Dimensions.webScreenWidth,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical:
                                              Dimensions.paddingSizeLarge),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              flex: 6,
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                  left: Dimensions
                                                      .paddingSizeLarge,
                                                  right: Dimensions
                                                      .paddingSizeLarge,
                                                  top: Dimensions
                                                      .paddingSizeLarge,
                                                  bottom: Dimensions
                                                      .paddingSizeSmall,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  borderRadius: const BorderRadius
                                                      .all(
                                                      Radius.circular(Dimensions
                                                          .radiusSizeDefault)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.01),
                                                        spreadRadius: 1,
                                                        blurRadius: 1),
                                                  ],
                                                ),
                                                child:
                                                    const CartProductListWidget(),
                                              )),
                                          const SizedBox(
                                              width:
                                                  Dimensions.paddingSizeLarge),
                                          Expanded(
                                              flex: 4,
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    CartDetailsWidget(
                                                      couponController:
                                                          _couponController,
                                                      total: total,
                                                      isSelfPickupActive:
                                                          isSelfPickupActive,
                                                      kmWiseCharge:
                                                          kmWiseCharge,
                                                      isFreeDelivery:
                                                          isFreeDelivery,
                                                      itemPrice: itemPrice,
                                                      tax: tax,
                                                      discount: discount,
                                                      deliveryCharge:
                                                          deliveryCharge,
                                                    ),
                                                    const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeLarge),
                                                    CartButtonWidget(
                                                      isLoggedin: _isLoggedIn,
                                                      itemDiscount: discount,
                                                      subTotal: subTotal,
                                                      configModel: configModel,
                                                      itemPrice: itemPrice,
                                                      total: total,
                                                      isFreeDelivery:
                                                          isFreeDelivery,
                                                      deliveryCharge:
                                                          deliveryCharge,
                                                    ),
                                                  ]))
                                        ],
                                      ),
                                    ))),
                          ),
                          //   const FooterWebWidget(footerType: FooterType.sliver),
                        ])
                  : NoDataWidget(
                      image: Images.favouriteNoDataImage,
                      title: getTranslated('empty_shopping_bag', context));
            },
          );
        }),
      ),
    );
  }

  double _getDeliveryChange(String? orderType, bool kmWiseCharge,
      double? deliveryCharge, couponType) {
    double deliveryAmount = 0;
    if (orderType == 'delivery' && !kmWiseCharge) {
      deliveryAmount = deliveryCharge ?? 0;
    } else {
      deliveryAmount = 0;
    }

    if (couponType == 'free_delivery') {
      deliveryAmount = 0;
    }

    return deliveryAmount;
  }
}
