import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/cart_model.dart';
import 'package:flutter_grocery/common/models/product_model.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/utill/product_type.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_directionality_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/common/widgets/on_hover_widget.dart';
import 'package:provider/provider.dart';

import 'wish_button_widget.dart';

// class ProductWidget extends StatelessWidget {
//   final Product product;
//   final String productType;
//   final bool isGrid;
//   final bool isCenter;
//   final bool isOfferScreen;

//   const ProductWidget({
//     Key? key,
//     required this.product,
//     this.productType = ProductType.dailyItem,
//     this.isGrid = false,
//     this.isCenter = false,
//     this.isOfferScreen = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     double? priceWithDiscount = PriceConverterHelper.convertWithDiscount(
//         product.price, product.discount, product.discountType);

//     return Consumer<CartProvider>(builder: (context, cartProvider, child) {
//       // Check if product exists in cart and retrieve its index
//       int? cartIndex = cartProvider.isExistInCart(
//         CartModel(
//           product.id,
//           product.image?.first ?? '',
//           product.name,
//           product.price,
//           priceWithDiscount,
//           1,
//           null,
//           0,
//           0,
//           product.capacity,
//           product.unit,
//           product.totalStock,
//           product,
//         ),
//       );

//       bool isExistInCart = cartIndex != null;
//       CartModel? cartModel =
//           isExistInCart ? cartProvider.cartList[cartIndex!] : null;

//       return isGrid
//           ? OnHoverWidget(
//               isItem: true,
//               child: _ProductGridWidget(
//                 cardIndex: cartIndex ?? 0,
//                 isCenter: isCenter,
//                 isExistInCart: isExistInCart,
//                 priceWithDiscount: priceWithDiscount ?? 0,
//                 product: product,
//                 productType: productType,
//                 cartModel: cartModel ??
//                     CartModel(
//                       product.id,
//                       product.image!.isNotEmpty ? product.image![0] : '',
//                       product.name,
//                       product.price,
//                       priceWithDiscount,
//                       1,
//                       null,
//                       0,
//                       0,
//                       product.capacity,
//                       product.unit,
//                       product.totalStock,
//                       product,
//                     ),
//                 stock: product.totalStock,
//                 isOfferScreen: isOfferScreen,
//               ))
//           : Padding(
//               padding:
//                   const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: ColorResources.scaffoldGrey,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: InkWell(
//                   onTap: () => Navigator.of(context).pushNamed(
//                     RouteHelper.getProductDetailsRoute(
//                       productId: product.id,
//                       formSearch: productType == ProductType.searchItem,
//                     ),
//                   ),
//                   child: OnHoverWidget(
//                     isItem: true,
//                     child: Container(
//                       height: 110,
//                       padding:
//                           const EdgeInsets.all(Dimensions.paddingSizeSmall),
//                       child: Row(
//                         children: [
//                           // Product Image
//                           Stack(
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                       color: Theme.of(context)
//                                           .primaryColor
//                                           .withOpacity(0.05)),
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: Theme.of(context).cardColor,
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(10),
//                                   child: CustomImageWidget(
//                                     image:
//                                         '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${product.image!.isNotEmpty ? product.image![0] : ''}',
//                                     height: 130,
//                                     width: 130,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Expanded(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: Dimensions.paddingSizeSmall),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // Product name and other details...
//                                   Text(product.name ?? '',
//                                       style: poppinsMedium),
//                                   // Add to Cart button or Quantity Controller
//                                   isExistInCart && cartModel != null
//                                       ? Row(
//                                           children: [
//                                             // Decrement Button
//                                             IconButton(
//                                               icon: const Icon(Icons.remove),
//                                               onPressed: () {
//                                                 if (cartModel.quantity! > 1) {
//                                                   cartProvider.setCartQuantity(
//                                                       false, cartIndex);
//                                                 } else {
//                                                   cartProvider
//                                                       .removeItemFromCart(
//                                                           cartIndex!, context);
//                                                 }
//                                               },
//                                             ),
//                                             // Display Quantity
//                                             Text(
//                                               cartModel.quantity.toString(),
//                                               style: const TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold),
//                                             ),
//                                             // Increment Button
//                                             IconButton(
//                                               icon: const Icon(Icons.add),
//                                               onPressed: () {
//                                                 if (cartModel.quantity! <
//                                                     cartModel.stock!) {
//                                                   cartProvider.setCartQuantity(
//                                                       true, cartIndex);
//                                                 } else {
//                                                   showCustomSnackBarHelper(
//                                                       'No more stock available');
//                                                 }
//                                               },
//                                             ),
//                                           ],
//                                         )
//                                       : GestureDetector(
//                                           onTap: () {
//                                             // When adding to cart for the first time
//                                             CartModel newCartModel = CartModel(
//                                               product.id,
//                                               product.image!.isNotEmpty
//                                                   ? product.image![0]
//                                                   : '',
//                                               product.name,
//                                               product.price,
//                                               priceWithDiscount,
//                                               1,
//                                               null,
//                                               product.price! -
//                                                   priceWithDiscount!,
//                                               product.tax ?? 0,
//                                               product.capacity,
//                                               product.unit,
//                                               product.totalStock,
//                                               product,
//                                             );
//                                             cartProvider
//                                                 .addToCart(newCartModel);
//                                           },
//                                           child: Container(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 8, vertical: 4),
//                                             decoration: BoxDecoration(
//                                               color: Theme.of(context)
//                                                   .primaryColor,
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                             child: const Text(
//                                               'Add to Cart',
//                                               style: TextStyle(
//                                                   color: Colors.white),
//                                             ),
//                                           ),
//                                         ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//     });
//   }
// }

class ProductWidget extends StatelessWidget {
  final Product product;
  final String productType;
  final bool isGrid;
  final bool isCenter;
  final bool isOfferScreen;

  const ProductWidget(
      {Key? key,
      required this.product,
      this.productType = ProductType.dailyItem,
      this.isGrid = false,
      this.isCenter = false,
      this.isOfferScreen = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? priceWithDiscount = 0;
    double? categoryDiscountAmount;
    if (product.categoryDiscount != null) {
      categoryDiscountAmount = PriceConverterHelper.convertWithDiscount(
        product.price,
        product.categoryDiscount?.discountAmount,
        product.categoryDiscount?.discountType,
        maxDiscount: product.categoryDiscount?.maximumAmount,
      );
    }

    priceWithDiscount = PriceConverterHelper.convertWithDiscount(
        product.price, product.discount, product.discountType);

    if (categoryDiscountAmount != null &&
        categoryDiscountAmount > 0 &&
        categoryDiscountAmount < priceWithDiscount!) {
      priceWithDiscount = categoryDiscountAmount;
    }

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        double price = 0;
        int? stock = 0;
        bool isExistInCart = false;
        int? cardIndex;
        CartModel? cartModel;
        if (product.variations!.isNotEmpty) {
          for (int index = 0; index < product.variations!.length; index++) {
            price = product.variations!.isNotEmpty
                ? (product.variations![index].price ?? 0)
                : (product.price ?? 0);
            stock = product.variations!.isNotEmpty
                ? product.variations![index].stock
                : product.totalStock;
            cartModel = CartModel(
                product.id,
                product.image!.isNotEmpty ? product.image![0] : '',
                product.name,
                price,
                PriceConverterHelper.convertWithDiscount(
                    price, product.discount, product.discountType),
                1,
                product.variations!.isNotEmpty
                    ? product.variations![index]
                    : null,
                (price -
                    PriceConverterHelper.convertWithDiscount(
                        price, product.discount, product.discountType)!),
                (price -
                    PriceConverterHelper.convertWithDiscount(
                        price, product.tax, product.taxType)!),
                product.capacity,
                product.unit,
                stock,
                product,
                product.approximateWeight,
                product.approximateUom);
            isExistInCart = cartProvider.isExistInCart(cartModel) != null;
            cardIndex = cartProvider.isExistInCart(cartModel);

            if (isExistInCart) {
              break;
            }
          }
        } else {
          price = product.price ?? 0;
          stock = product.totalStock;
          cartModel = CartModel(
            product.id,
            (product.image?.isNotEmpty ?? false) ? product.image![0] : '',
            product.name,
            price,
            PriceConverterHelper.convertWithDiscount(
                price, product.discount, product.discountType),
            1,
            null,
            (price -
                PriceConverterHelper.convertWithDiscount(
                    price, product.discount, product.discountType)!),
            (price -
                PriceConverterHelper.convertWithDiscount(
                    price, product.tax, product.taxType)!),
            product.capacity,
            product.unit,
            stock,
            product,
            product.approximateWeight,
            product.approximateUom,
          );

          isExistInCart = cartProvider.isExistInCart(cartModel) != null;
          cardIndex = cartProvider.isExistInCart(cartModel);
        }

        return isGrid
            ? // SizedBox()
            OnHoverWidget(
                isItem: true,
                child: _ProductGridWidget(
                  cardIndex: cardIndex,
                  isCenter: isCenter,
                  isExistInCart: isExistInCart,
                  priceWithDiscount: priceWithDiscount ?? 0,
                  product: product,
                  productType: productType,
                  cartModel: cartModel,
                  stock: stock,
                  isOfferScreen: isOfferScreen,
                ))
            : Padding(
                padding:
                    const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorResources.scaffoldGrey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    onTap: () => Navigator.of(context).pushNamed(
                      RouteHelper.getProductDetailsRoute(
                        productId: product.id,
                        formSearch: productType == ProductType.searchItem,
                      ),
                    ),
                    child: OnHoverWidget(
                      isItem: true,
                      child: Container(
                        height: 110,
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // color: Theme.of(context).cardColor,
                          // boxShadow: [
                          //   BoxShadow(
                          //       color: Colors.black.withOpacity(0.05),
                          //       offset: const Offset(0, 4),
                          //       blurRadius: 7,
                          //       spreadRadius: 0.1)
                          // ],
                        ),
                        child: Row(children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.05)),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).cardColor,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CustomImageWidget(
                                    image:
                                        '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${product.image!.isNotEmpty ? product.image![0] : ''}',
                                    height: 130,
                                    width: 130,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              product.discount != 0
                                  ? Positioned(
                                      top: 5,
                                      left: 5,
                                      child: _DiscountTag(product: product),
                                    )
                                  : const SizedBox(),
                              // Positioned(
                              //   top: ResponsiveHelper.isDesktop(context)
                              //       ? null
                              //       : 5,
                              //   right:
                              //       ResponsiveHelper.isDesktop(context) ? 5 : 5,
                              //   bottom: ResponsiveHelper.isDesktop(context)
                              //       ? 5
                              //       : null,
                              //   child: !isExistInCart
                              //       ? Tooltip(
                              //           message: getTranslated(
                              //               'click_to_add_to_your_cart',
                              //               context),
                              //           child: InkWell(
                              //               onTap: () {
                              //                 if (product.variations == null ||
                              //                     product.variations!.isEmpty) {
                              //                   if (isExistInCart) {
                              //                     showCustomSnackBarHelper(
                              //                         'already_added'.tr);
                              //                   } else if (stock! < 1) {
                              //                     showCustomSnackBarHelper(
                              //                         'out_of_stock'.tr);
                              //                   } else {
                              //                     Provider.of<CartProvider>(
                              //                             context,
                              //                             listen: false)
                              //                         .addToCart(cartModel!);
                              //                     showCustomSnackBarHelper(
                              //                         'added_to_cart'.tr,
                              //                         isError: false);
                              //                   }
                              //                 } else {
                              //                   Navigator.of(context).pushNamed(
                              //                     RouteHelper
                              //                         .getProductDetailsRoute(
                              //                       productId: product.id,
                              //                       formSearch: productType ==
                              //                           ProductType.searchItem,
                              //                     ),
                              //                   );
                              //                 }
                              //               },
                              //               child: Container(
                              //                 padding: const EdgeInsets.all(5),
                              //                 margin: const EdgeInsets.all(2),
                              //                 alignment: Alignment.center,
                              //                 decoration: BoxDecoration(
                              //                   border: Border.all(
                              //                       width: 1,
                              //                       color: Theme.of(context)
                              //                           .primaryColor
                              //                           .withOpacity(0.05)),
                              //                   borderRadius:
                              //                       BorderRadius.circular(
                              //                           Dimensions
                              //                               .radiusSizeDefault),
                              //                   color:
                              //                       Theme.of(context).cardColor,
                              //                 ),
                              //                 child: Icon(
                              //                     Icons.shopping_cart_outlined,
                              //                     color: Theme.of(context)
                              //                         .primaryColor),
                              //               )),
                              //         )
                              //       : Consumer<CartProvider>(
                              //           builder: (context, cart, child) =>
                              //               RotatedBox(
                              //             quarterTurns:
                              //                 ResponsiveHelper.isDesktop(
                              //                         context)
                              //                     ? 0
                              //                     : 3,
                              //             child: Container(
                              //               decoration: BoxDecoration(
                              //                 border: Border.all(
                              //                     width: 1,
                              //                     color: Theme.of(context)
                              //                         .primaryColor
                              //                         .withOpacity(0.05)),
                              //                 borderRadius:
                              //                     BorderRadius.circular(8),
                              //                 color:
                              //                     Theme.of(context).cardColor,
                              //               ),
                              //               child: Row(children: [
                              //                 InkWell(
                              //                   onTap: () {
                              //                     if (cart.cartList[cardIndex!]
                              //                             .quantity! >
                              //                         1) {
                              //                       Provider.of<CartProvider>(
                              //                               context,
                              //                               listen: false)
                              //                           .setCartQuantity(
                              //                               false, cardIndex,
                              //                               context: context,
                              //                               showMessage: true);
                              //                     } else {
                              //                       Provider.of<CartProvider>(
                              //                               context,
                              //                               listen: false)
                              //                           .removeItemFromCart(
                              //                               cardIndex, context);
                              //                     }
                              //                   },
                              //                   child: RotatedBox(
                              //                     quarterTurns: ResponsiveHelper
                              //                             .isDesktop(context)
                              //                         ? 0
                              //                         : 1,
                              //                     child: Padding(
                              //                       padding: EdgeInsets.symmetric(
                              //                           horizontal: ResponsiveHelper
                              //                                   .isDesktop(
                              //                                       context)
                              //                               ? Dimensions
                              //                                   .paddingSizeSmall
                              //                               : Dimensions
                              //                                   .paddingSizeExtraSmall,
                              //                           vertical: Dimensions
                              //                               .paddingSizeExtraSmall),
                              //                       child: Icon(Icons.remove,
                              //                           size: 20,
                              //                           color: Theme.of(context)
                              //                               .textTheme
                              //                               .bodyLarge!
                              //                               .color),
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 RotatedBox(
                              //                   quarterTurns:
                              //                       ResponsiveHelper.isDesktop(
                              //                               context)
                              //                           ? 0
                              //                           : 1,
                              //                   child: Text(
                              //                       cart.cartList[cardIndex!]
                              //                           .quantity
                              //                           .toString(),
                              //                       style: poppinsSemiBold.copyWith(
                              //                           fontSize: Dimensions
                              //                               .fontSizeExtraLarge,
                              //                           color: Theme.of(context)
                              //                               .textTheme
                              //                               .bodyLarge!
                              //                               .color)),
                              //                 ),
                              //                 InkWell(
                              //                   onTap: () {
                              //                     if (cart
                              //                                 .cartList[
                              //                                     cardIndex!]
                              //                                 .product!
                              //                                 .maximumOrderQuantity ==
                              //                             null ||
                              //                         cart.cartList[cardIndex]
                              //                                 .quantity! <
                              //                             cart
                              //                                 .cartList[
                              //                                     cardIndex]
                              //                                 .product!
                              //                                 .maximumOrderQuantity!) {
                              //                       if (cart.cartList[cardIndex]
                              //                               .quantity! <
                              //                           cart.cartList[cardIndex]
                              //                               .stock!) {
                              //                         cart.setCartQuantity(
                              //                             true, cardIndex,
                              //                             showMessage: true,
                              //                             context: context);
                              //                       } else {
                              //                         showCustomSnackBarHelper(
                              //                             getTranslated(
                              //                                 'out_of_stock',
                              //                                 context));
                              //                       }
                              //                     } else {
                              //                       showCustomSnackBarHelper(
                              //                           '${getTranslated('you_can_add_max', context)} ${cart.cartList[cardIndex].product!.maximumOrderQuantity} ${getTranslated(cart.cartList[cardIndex].product!.maximumOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
                              //                     }
                              //                   },
                              //                   child: Padding(
                              //                     padding: const EdgeInsets
                              //                         .symmetric(
                              //                         horizontal: Dimensions
                              //                             .paddingSizeSmall,
                              //                         vertical: Dimensions
                              //                             .paddingSizeExtraSmall),
                              //                     child: Icon(Icons.add,
                              //                         size: 20,
                              //                         color: Theme.of(context)
                              //                             .textTheme
                              //                             .bodyLarge!
                              //                             .color),
                              //                   ),
                              //                 ),
                              //               ]),
                              //             ),
                              //           ),
                              //         ),
                              // )
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    product.rating != null &&
                                            product.rating!.isNotEmpty
                                        ? Row(
                                            mainAxisAlignment: isCenter
                                                ? MainAxisAlignment.center
                                                : MainAxisAlignment.start,
                                            children: [
                                                const Icon(Icons.star_rounded,
                                                    color: ColorResources
                                                        .ratingColor,
                                                    size: 20),
                                                const SizedBox(
                                                    width: Dimensions
                                                        .paddingSizeExtraSmall),
                                                Text(
                                                    product.rating!.isNotEmpty
                                                        ? double.parse(product
                                                                .rating![0]
                                                                .average!)
                                                            .toStringAsFixed(1)
                                                        : '0.0',
                                                    style:
                                                        poppinsRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault,
                                                    )),
                                              ])
                                        : const SizedBox(),
                                    Tooltip(
                                        message: product.name,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          child: Text(
                                            product.name ?? '',
                                            style: poppinsMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeDefault),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )),
                                    Text('${product.capacity} ${product.unit}',
                                        style: poppinsMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context)
                                                .disabledColor)),
                                    Flexible(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                product.price! >
                                                        priceWithDiscount!
                                                    ? CustomDirectionalityWidget(
                                                        child: Text(
                                                        PriceConverterHelper
                                                            .convertPrice(
                                                                context,
                                                                product.price),
                                                        style: poppinsRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ))
                                                    : const SizedBox(),
                                                product.price! >
                                                        priceWithDiscount
                                                    ? const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeExtraSmall)
                                                    : const SizedBox(),
                                                CustomDirectionalityWidget(
                                                    child: Text(
                                                  PriceConverterHelper
                                                      .convertPrice(context,
                                                          priceWithDiscount),
                                                  style:
                                                      poppinsSemiBold.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                WishButtonWidget(
                                    product: product,
                                    edgeInset: const EdgeInsets.all(5)),
                                Consumer<CartProvider>(
                                  builder: (context, cart, child) => Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.05)),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(context).cardColor,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!isExistInCart) {
                                          if (product.variations == null ||
                                              product.variations!.isEmpty) {
                                            if (isExistInCart) {
                                              showCustomSnackBarHelper(
                                                  'already_added'.tr);
                                            } else if (stock! < 1) {
                                              showCustomSnackBarHelper(
                                                  'out_of_stock'.tr);
                                            } else {
                                              Provider.of<CartProvider>(context,
                                                      listen: false)
                                                  .addToCart(cartModel!);
                                              showCustomSnackBarHelper(
                                                  'added_to_cart'.tr,
                                                  isError: false);
                                            }
                                          } else {
                                            Navigator.of(context).pushNamed(
                                              RouteHelper
                                                  .getProductDetailsRoute(
                                                productId: product.id,
                                                formSearch: productType ==
                                                    ProductType.searchItem,
                                              ),
                                            );
                                          }
                                        } else {
                                          if (cart.cartList[cardIndex!].product!
                                                      .maximumOrderQuantity ==
                                                  null ||
                                              cart.cartList[cardIndex]
                                                      .quantity! <
                                                  cart
                                                      .cartList[cardIndex]
                                                      .product!
                                                      .maximumOrderQuantity!) {
                                            if (cart.cartList[cardIndex]
                                                    .quantity! <
                                                cart.cartList[cardIndex]
                                                    .stock!) {
                                              cart.setCartQuantity(
                                                  true, cardIndex,
                                                  showMessage: true,
                                                  context: context);
                                            } else {
                                              showCustomSnackBarHelper(
                                                  getTranslated(
                                                      'out_of_stock', context));
                                            }
                                          } else {
                                            showCustomSnackBarHelper(
                                                '${getTranslated('you_can_add_max', context)} ${cart.cartList[cardIndex].product!.maximumOrderQuantity} ${getTranslated(cart.cartList[cardIndex].product!.maximumOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
                                          }
                                        }
                                      },
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        child: const Icon(
                                          Icons.add,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }
}

class _ProductGridWidget extends StatelessWidget {
  final bool isExistInCart;
  final int? stock;
  final CartModel? cartModel;
  final int? cardIndex;
  final double priceWithDiscount;
  final Product product;
  final String productType;
  final bool isCenter;
  final bool isOfferScreen;

  const _ProductGridWidget({
    Key? key,
    required this.isExistInCart,
    this.stock,
    this.cartModel,
    required this.cardIndex,
    required this.priceWithDiscount,
    required this.product,
    required this.productType,
    required this.isCenter,
    required this.isOfferScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(RouteHelper.getProductDetailsRoute(
              productId: product.id,
              formSearch: productType == ProductType.searchItem,
            ));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSizeTen),
                        child: CustomImageWidget(
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.width /
                              (isOfferScreen ? 2 : 3),
                          width: MediaQuery.of(context).size.width /
                              (isOfferScreen ? 2 : 3),
                          image:
                              '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${(product.image?.isNotEmpty ?? false) ? product.image![0] : ''}',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeExtraSmall),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Tooltip(
                            message:
                                '${product.name ?? ''} ${product.capacity} ${product.unit}',
                            child: Text(
                              '${product.name ?? ''} ${product.capacity} ${product.unit}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign:
                                  isCenter ? TextAlign.center : TextAlign.start,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            PriceConverterHelper.convertPrice(
                                context, priceWithDiscount),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        int quantity = isExistInCart
                            ? cart.cartList[cardIndex!].quantity ?? 0
                            : 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall),
                          child: isExistInCart && quantity > 0
                              ? SizedBox(
                                  width: 100, // Fixed width to avoid shifting
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Decrease quantity button with CircleAvatar design
                                      GestureDetector(
                                        onTap: () {
                                          if (quantity > 1) {
                                            cart.setCartQuantity(
                                                false, cardIndex,
                                                showMessage: true,
                                                context: context);
                                          } else {
                                            cart.removeItemFromCart(
                                                cardIndex!, context);
                                          }
                                        },
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          child: const Icon(
                                            Icons.remove,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                      // Display current quantity
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          '$quantity',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ),

                                      // Increment button with CircleAvatar design
                                      GestureDetector(
                                        onTap: () {
                                          // if (quantity <
                                          //     cart.cartList[cardIndex!]
                                          //         .stock!) {
                                          cart.setCartQuantity(true, cardIndex,
                                              showMessage: true,
                                              context: context);
                                          // } else {
                                          //   showCustomSnackBarHelper(
                                          //       getTranslated(
                                          //           'out_of_stock', context));
                                          // }
                                        },
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          child: const Icon(
                                            Icons.add,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    if (!isExistInCart) {
                                      if (product.variations == null ||
                                          product.variations!.isEmpty) {
                                        if (stock! < 1) {
                                          showCustomSnackBarHelper(
                                              'out_of_stock'.tr);
                                        } else {
                                          Provider.of<CartProvider>(context,
                                                  listen: false)
                                              .addToCart(cartModel!);
                                          showCustomSnackBarHelper(
                                              'added_to_cart'.tr,
                                              isError: false);
                                        }
                                      } else {
                                        Navigator.of(context).pushNamed(
                                          RouteHelper.getProductDetailsRoute(
                                            productId: product.id,
                                            formSearch: productType ==
                                                ProductType.searchItem,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    child: const Icon(
                                      Icons.add,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        );
                      },
                    )
                  ],
                ),
                if (product.discount != 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _DiscountTag(product: product),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: WishButtonWidget(
                      product: product, edgeInset: const EdgeInsets.all(5.0)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// class _ProductGridWidget extends StatelessWidget {
//   final bool isExistInCart;
//   final int? stock;
//   final CartModel? cartModel;
//   final int? cardIndex;
//   final double priceWithDiscount;
//   final Product product;
//   final String productType;
//   final bool isCenter;
//   final bool isOfferScreen;

//   const _ProductGridWidget(
//       {Key? key,
//       required this.isExistInCart,
//       this.stock,
//       this.cartModel,
//       required this.cardIndex,
//       required this.priceWithDiscount,
//       required this.product,
//       required this.productType,
//       required this.isCenter,
//       required this.isOfferScreen})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           // hoverColor: Colors.transparent,
//           // borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
//           onTap: () {
//             Navigator.of(context).pushNamed(RouteHelper.getProductDetailsRoute(
//               productId: product.id,
//               formSearch: productType == ProductType.searchItem,
//             ));
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).cardColor,
//               borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
//               // boxShadow: [
//               //   BoxShadow(
//               //     color: Colors.black.withOpacity(0.05),
//               //     offset: const Offset(0, 4),
//               //     blurRadius: 7,
//               //     spreadRadius: 0.1,
//               //   ),
//               // ],
//             ),
//             child: Stack(
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Stack(
//                       children: [
//                         Padding(
//                           padding:
//                               const EdgeInsets.only(left: 5, right: 5, top: 5),
//                           child: Container(
//                             margin: const EdgeInsets.only(bottom: 0),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(0),
//                             ),
//                           ),
//                         ),
//                         Container(
//                           width: MediaQuery.of(context).size.width /
//                               (isOfferScreen ? 2 : 3),
//                           height: MediaQuery.of(context).size.width /
//                               (isOfferScreen ? 2 : 3),
//                           margin: const EdgeInsets.only(
//                               top: Dimensions.paddingSizeSmall,
//                               left: Dimensions.paddingSizeSmall,
//                               right: Dimensions.paddingSizeSmall),
//                           decoration: const BoxDecoration(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(Dimensions.radiusSizeTen),
//                             ),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: const BorderRadius.all(
//                               Radius.circular(Dimensions.radiusSizeTen),
//                             ),
//                             child: CustomImageWidget(
//                               fit: BoxFit.cover,
//                               height: MediaQuery.of(context).size.width / 3,
//                               width: MediaQuery.of(context).size.width / 3,
//                               image:
//                                   '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${(product.image?.isNotEmpty ?? false) ? product.image![0] : ''}',
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: Dimensions.paddingSizeSmall,
//                           vertical: Dimensions.paddingSizeExtraSmall),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // product.rating != null ? Row(mainAxisAlignment: isCenter ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
//                           //   const Icon(Icons.star_rounded, color: ColorResources.ratingColor, size: 20),
//                           //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),

//                           //   Text(product.rating!.isNotEmpty ? double.parse(product.rating![0].average!).toStringAsFixed(1) : '0.0', style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),

//                           // ]) : const SizedBox(),

//                           Tooltip(
//                             message:
//                                 '${product.name ?? ''} ${product.capacity} ${product.unit}',
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 3),
//                               child: Text(
//                                 '${product.name ?? ''} ${product.capacity} ${product.unit}',
//                                 style: poppinsSemiBold.copyWith(
//                                   fontSize: Dimensions.fontSizeDefault,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 textAlign: isCenter
//                                     ? TextAlign.center
//                                     : TextAlign.start,
//                               ),
//                             ),
//                           ),

//                           isCenter
//                               ? CustomDirectionalityWidget(
//                                   child: RichText(
//                                   overflow: TextOverflow.ellipsis,
//                                   textAlign: TextAlign.center,
//                                   maxLines: 2,
//                                   text: TextSpan(
//                                     children: [
//                                       if ((product.price ?? 0) >
//                                           priceWithDiscount)
//                                         TextSpan(
//                                           style: poppinsRegular.copyWith(
//                                             fontSize:
//                                                 Dimensions.fontSizeDefault,
//                                             color:
//                                                 Theme.of(context).disabledColor,
//                                             decoration:
//                                                 TextDecoration.lineThrough,
//                                             decorationColor: Colors.red,
//                                           ),
//                                           text:
//                                               PriceConverterHelper.convertPrice(
//                                                   context,
//                                                   (product.price ?? 0)),
//                                         ),
//                                       if ((product.price ?? 0) >
//                                           priceWithDiscount)
//                                         const TextSpan(text: '  '),
//                                       TextSpan(
//                                         style: poppinsSemiBold.copyWith(
//                                           fontSize: Dimensions.fontSizeDefault,
//                                           color: Theme.of(context)
//                                               .textTheme
//                                               .titleMedium
//                                               ?.color,
//                                         ),
//                                         text: PriceConverterHelper.convertPrice(
//                                             context, priceWithDiscount),
//                                       ),
//                                     ],
//                                   ),
//                                 ))
//                               : Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Column(
//                                       children: [
//                                         // Text(
//                                         //   '${product.capacity} ${product.unit}',
//                                         //   style: poppinsRegular.copyWith(
//                                         //       fontSize:
//                                         //           Dimensions.fontSizeSmall,
//                                         //       color: Theme.of(context)
//                                         //           .disabledColor),
//                                         //   maxLines: 1,
//                                         //   overflow: TextOverflow.ellipsis,
//                                         // ),
//                                         // const Spacer(),
//                                         const SizedBox(height: 12),
//                                         product.price! > priceWithDiscount
//                                             ? CustomDirectionalityWidget(
//                                                 child: Text(
//                                                   PriceConverterHelper
//                                                       .convertPrice(context,
//                                                           product.price),
//                                                   style:
//                                                       poppinsRegular.copyWith(
//                                                     fontSize: Dimensions
//                                                         .fontSizeSmall,
//                                                     color: Theme.of(context)
//                                                         .disabledColor,
//                                                     decoration: TextDecoration
//                                                         .lineThrough,
//                                                   ),
//                                                 ),
//                                               )
//                                             : const SizedBox(),
//                                         CustomDirectionalityWidget(
//                                             child: Text(
//                                           PriceConverterHelper.convertPrice(
//                                               context, priceWithDiscount),
//                                           style: poppinsSemiBold.copyWith(
//                                               fontSize:
//                                                   Dimensions.fontSizeLarge),
//                                         )),
//                                       ],
//                                     ),
//                                     Consumer<CartProvider>(
//                                       builder: (context, cart, child) =>
//                                           RotatedBox(
//                                         quarterTurns: 3,
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             border: Border.all(
//                                                 width: 1,
//                                                 color: Theme.of(context)
//                                                     .primaryColor
//                                                     .withOpacity(0.05)),
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                             color: Theme.of(context).cardColor,
//                                           ),
//                                           child: GestureDetector(
//                                             onTap: () {
//                                               if (!isExistInCart) {
//                                                 if (product.variations ==
//                                                         null ||
//                                                     product
//                                                         .variations!.isEmpty) {
//                                                   if (isExistInCart) {
//                                                     showCustomSnackBarHelper(
//                                                         'already_added'.tr);
//                                                   } else if (stock! < 1) {
//                                                     showCustomSnackBarHelper(
//                                                         'out_of_stock'.tr);
//                                                   } else {
//                                                     Provider.of<CartProvider>(
//                                                             context,
//                                                             listen: false)
//                                                         .addToCart(cartModel!);
//                                                     showCustomSnackBarHelper(
//                                                         'added_to_cart'.tr,
//                                                         isError: false);
//                                                   }
//                                                 } else {
//                                                   Navigator.of(context)
//                                                       .pushNamed(
//                                                     RouteHelper
//                                                         .getProductDetailsRoute(
//                                                       productId: product.id,
//                                                       formSearch: productType ==
//                                                           ProductType
//                                                               .searchItem,
//                                                     ),
//                                                   );
//                                                 }
//                                               } else {
//                                                 if (cart
//                                                             .cartList[
//                                                                 cardIndex!]
//                                                             .product!
//                                                             .maximumOrderQuantity ==
//                                                         null ||
//                                                     cart.cartList[cardIndex!]
//                                                             .quantity! <
//                                                         cart
//                                                             .cartList[
//                                                                 cardIndex!]
//                                                             .product!
//                                                             .maximumOrderQuantity!) {
//                                                   if (cart.cartList[cardIndex!]
//                                                           .quantity! <
//                                                       cart.cartList[cardIndex!]
//                                                           .stock!) {
//                                                     cart.setCartQuantity(
//                                                         true, cardIndex,
//                                                         showMessage: true,
//                                                         context: context);
//                                                   } else {
//                                                     showCustomSnackBarHelper(
//                                                         getTranslated(
//                                                             'out_of_stock',
//                                                             context));
//                                                   }
//                                                 } else {
//                                                   showCustomSnackBarHelper(
//                                                       '${getTranslated('you_can_add_max', context)} ${cart.cartList[cardIndex!].product!.maximumOrderQuantity} ${getTranslated(cart.cartList[cardIndex!].product!.maximumOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
//                                                 }
//                                               }
//                                             },
//                                             child: CircleAvatar(
//                                               radius: 12,
//                                               backgroundColor: Theme.of(context)
//                                                   .primaryColor,
//                                               child: const Icon(
//                                                 Icons.add,
//                                                 size: 20,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 product.discount != 0
//                     ? Positioned.fill(
//                         top: 17,
//                         left: 17,
//                         child: Align(
//                           alignment: Alignment.topLeft,
//                           child: _DiscountTag(product: product),
//                         ),
//                       )
//                     : const SizedBox(),
//                 Positioned.fill(
//                   top: 17,
//                   right: 17,
//                   child: Align(
//                     alignment: Alignment.topRight,
//                     child: WishButtonWidget(
//                         product: product, edgeInset: const EdgeInsets.all(5.0)),
//                   ),
//                 ),
//                 // Positioned.fill(
//                 //   right: 17,
//                 //   top: 60,
//                 //   child: Align(
//                 //     alignment: Alignment.topRight,
//                 //     child: !isExistInCart
//                 //         ? Tooltip(
//                 //             message:
//                 //                 getTranslated('click_to_add_to_your_cart', context),
//                 //             child: InkWell(
//                 //               onTap: () {
//                 //                 if (product.variations == null ||
//                 //                     product.variations!.isEmpty) {
//                 //                   if (isExistInCart) {
//                 //                     showCustomSnackBarHelper('already_added'.tr);
//                 //                   } else if (stock! < 1) {
//                 //                     showCustomSnackBarHelper('out_of_stock'.tr);
//                 //                   } else {
//                 //                     Provider.of<CartProvider>(context, listen: false)
//                 //                         .addToCart(cartModel!);
//                 //                     showCustomSnackBarHelper('added_to_cart'.tr,
//                 //                         isError: false);
//                 //                   }
//                 //                 } else {
//                 //                   Navigator.of(context).pushNamed(
//                 //                     RouteHelper.getProductDetailsRoute(
//                 //                       productId: product.id,
//                 //                       formSearch:
//                 //                           productType == ProductType.searchItem,
//                 //                     ),
//                 //                   );
//                 //                 }
//                 //               },
//                 //               child: Container(
//                 //                   padding: const EdgeInsets.all(5),
//                 //                   decoration: BoxDecoration(
//                 //                     color: Theme.of(context).cardColor,
//                 //                     borderRadius: BorderRadius.circular(
//                 //                         Dimensions.radiusSizeDefault),
//                 //                     border: Border.all(
//                 //                         color: Theme.of(context)
//                 //                             .primaryColor
//                 //                             .withOpacity(0.05)),
//                 //                   ),
//                 //                   child: Icon(
//                 //                     Icons.shopping_cart_outlined,
//                 //                     color: Theme.of(context).primaryColor,
//                 //                     size: Dimensions.paddingSizeLarge,
//                 //                   )),
//                 //             ),
//                 //           )
//                 //         : Consumer<CartProvider>(
//                 //             builder: (context, cart, child) => RotatedBox(
//                 //               quarterTurns: 3,
//                 //               child: Container(
//                 //                 decoration: BoxDecoration(
//                 //                   border: Border.all(
//                 //                       width: 1,
//                 //                       color: Theme.of(context)
//                 //                           .primaryColor
//                 //                           .withOpacity(0.05)),
//                 //                   borderRadius: BorderRadius.circular(8),
//                 //                   color: Theme.of(context).cardColor,
//                 //                 ),
//                 //                 child: Row(mainAxisSize: MainAxisSize.min, children: [
//                 //                   InkWell(
//                 //                     onTap: () {
//                 //                       if (cart.cartList[cardIndex!].quantity! > 1) {
//                 //                         Provider.of<CartProvider>(context,
//                 //                                 listen: false)
//                 //                             .setCartQuantity(false, cardIndex,
//                 //                                 context: context, showMessage: true);
//                 //                       } else {
//                 //                         Provider.of<CartProvider>(context,
//                 //                                 listen: false)
//                 //                             .removeItemFromCart(cardIndex!, context);
//                 //                       }
//                 //                     },
//                 //                     child: RotatedBox(
//                 //                       quarterTurns: 1,
//                 //                       child: Padding(
//                 //                         padding: const EdgeInsets.symmetric(
//                 //                             horizontal:
//                 //                                 Dimensions.paddingSizeExtraSmall,
//                 //                             vertical:
//                 //                                 Dimensions.paddingSizeExtraSmall),
//                 //                         child: Icon(
//                 //                           Icons.remove,
//                 //                           size: Dimensions.paddingSizeLarge,
//                 //                           color: Theme.of(context)
//                 //                               .textTheme
//                 //                               .bodyLarge
//                 //                               ?.color,
//                 //                         ),
//                 //                       ),
//                 //                     ),
//                 //                   ),
//                 //                   RotatedBox(
//                 //                     quarterTurns: 1,
//                 //                     child: Text(
//                 //                       cart.cartList[cardIndex!].quantity.toString(),
//                 //                       style: poppinsSemiBold.copyWith(
//                 //                           fontSize: Dimensions.fontSizeExtraLarge,
//                 //                           color: Theme.of(context)
//                 //                               .textTheme
//                 //                               .bodyLarge!
//                 //                               .color),
//                 //                     ),
//                 //                   ),
//                 //                   InkWell(
//                 //                     onTap: () {
//                 //                       if (cart.cartList[cardIndex!].product!
//                 //                                   .maximumOrderQuantity ==
//                 //                               null ||
//                 //                           cart.cartList[cardIndex!].quantity! <
//                 //                               cart.cartList[cardIndex!].product!
//                 //                                   .maximumOrderQuantity!) {
//                 //                         if (cart.cartList[cardIndex!].quantity! <
//                 //                             cart.cartList[cardIndex!].stock!) {
//                 //                           cart.setCartQuantity(true, cardIndex,
//                 //                               showMessage: true, context: context);
//                 //                         } else {
//                 //                           showCustomSnackBarHelper(
//                 //                               getTranslated('out_of_stock', context));
//                 //                         }
//                 //                       } else {
//                 //                         showCustomSnackBarHelper(
//                 //                             '${getTranslated('you_can_add_max', context)} ${cart.cartList[cardIndex!].product!.maximumOrderQuantity} ${getTranslated(cart.cartList[cardIndex!].product!.maximumOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
//                 //                       }
//                 //                     },
//                 //                     child: Padding(
//                 //                       padding: const EdgeInsets.symmetric(
//                 //                           horizontal: Dimensions.paddingSizeSmall,
//                 //                           vertical: Dimensions.paddingSizeExtraSmall),
//                 //                       child: Icon(Icons.add,
//                 //                           size: 20,
//                 //                           color: Theme.of(context)
//                 //                               .textTheme
//                 //                               .bodyLarge!
//                 //                               .color),
//                 //                     ),
//                 //                   ),
//                 //                 ]),
//                 //               ),
//                 //             ),
//                 //           ),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

class _DiscountTag extends StatelessWidget {
  const _DiscountTag({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(Dimensions.radiusSizeTen),
          bottomLeft: Radius.circular(Dimensions.radiusSizeTen),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              product.discountType == 'percent'
                  ? '-${product.discount} %'
                  : '-${PriceConverterHelper.convertPrice(context, product.discount)}',
              style: poppinsRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).cardColor),
            ),
          ),
        ],
      ),
    );
  }
}
