import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/cart_model.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/features/cart/widgets/discounted_price_widget.dart';
import 'package:flutter_grocery/features/coupon/providers/coupon_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartModel cart;
  final int index;
  const CartItemWidget({Key? key, required this.cart, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var specialRequestController = TextEditingController();
    specialRequestController.text = cart.remarks ?? '';
    final CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    String? variationText = _getVariationValue();

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10)),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            RouteHelper.getProductDetailsRoute(productId: cart.product?.id),
          );
        },
        child: Stack(children: [
          const Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child: Icon(Icons.delete, color: Colors.white, size: 50),
          ),
          Dismissible(
            key: UniqueKey(),
            onDismissed: (DismissDirection direction) {
              cartProvider.setExistData(null);
              Provider.of<CouponProvider>(context, listen: false)
                  .removeCouponData(false);
              cartProvider.removeItemFromCart(index, context);
            },
            child: Container(
              // padding: const EdgeInsets.symmetric(
              //     vertical: Dimensions.paddingSizeSmall,
              //     horizontal: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 900 : 200]!,
                //     blurRadius: 5,
                //     spreadRadius: 1,
                //   )
                // ],
              ),
              child: Row(
                  crossAxisAlignment: ResponsiveHelper.isDesktop(context)
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.center,
                  mainAxisAlignment: ResponsiveHelper.isDesktop(context)
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.05)),
                              borderRadius: BorderRadius.circular(10)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CustomImageWidget(
                              image:
                                  '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${cart.image}',
                              // height:
                              //     ResponsiveHelper.isDesktop(context) ? 100 : 70,
                              // width: ResponsiveHelper.isDesktop(context) ? 100 : 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        cart.discount != 0
                            ? Positioned(
                                top: 5,
                                left: -1,
                                child: _DiscountTag(cart: cart),
                              )
                            : const SizedBox(),
                      ],
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    !ResponsiveHelper.isDesktop(context)
                        ? Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    cart.name ?? '',
                                    style: poppinsBold.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // const SizedBox(
                                  //     height: Dimensions.paddingSizeExtraSmall),

                                  if (cart.product?.variations?.isNotEmpty ??
                                      false)
                                    Row(children: [
                                      Text(
                                        '${getTranslated('variation', context)}: ',
                                        style: poppinsRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                        ),
                                      ),
                                      Flexible(
                                          child: Text(variationText!,
                                              style: poppinsRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeSmall,
                                                color: Theme.of(context)
                                                    .disabledColor,
                                              ))),
                                    ]),
                                  Row(
                                    children: [
                                      Text(
                                        cart?.approximateWeight ?? '',
                                        style: poppinsMedium.copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                          fontSize: Dimensions.fontSizeDefault,
                                        ),
                                      ),
                                      Text(
                                        "${cart?.approximateUom ?? ''} (Approx)",
                                        style: poppinsMedium.copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                          fontSize: Dimensions.fontSizeDefault,
                                        ),
                                      ),
                                    ],
                                  ),
                                  cart.remarks != null
                                      ? Text(
                                          "${cart.remarks}",
                                          style: poppinsMedium.copyWith(
                                            color:
                                                Theme.of(context).disabledColor,
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                          ),
                                          maxLines:
                                              2, // Limit the text to 2 lines
                                          overflow: TextOverflow
                                              .ellipsis, // Append "..." if the text overflows
                                        )
                                      : SizedBox(),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        //  showDragHandle: true,
                                        isDismissible: true,
                                        context: context,
                                        isScrollControlled:
                                            true, // Allows the bottom sheet to adjust for the keyboard
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (context) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              left: 16.0,
                                              right: 16.0,
                                              top: 16.0,
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom, // Adjust padding for keyboard
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize
                                                  .min, // Wraps content
                                              children: [
                                                Text(
                                                  getTranslated(
                                                      'Edit Special Request',
                                                      context),
                                                  style:
                                                      poppinsSemiBold.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Container(
                                                  height:
                                                      150, // Increased height for the input field
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[
                                                        200], // Off-white background color
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10), // Rounded corners
                                                  ),
                                                  child: TextField(
                                                    controller:
                                                        specialRequestController,
                                                    maxLines:
                                                        null, // Allow multiple lines
                                                    expands:
                                                        true, // Make the field fill the container height
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Enter your special request',
                                                      border: InputBorder
                                                          .none, // Remove border
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    cartProvider.addRemarks(
                                                        index,
                                                        specialRequestController
                                                            .text
                                                            .trim());
                                                    // Handle saving or updating the special request
                                                    Navigator.pop(
                                                        context); // Close the bottom sheet
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .green, // Change this to your desired color
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16.0,
                                                        vertical:
                                                            12.0), // Adjust padding if needed
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10), // Rounded corners
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Save Request',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01,
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          getTranslated(
                                              'Edit Special Request', context),
                                          style: poppinsSemiBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: Theme.of(context)
                                                .disabledColor
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                        Icon(
                                          Icons.edit,
                                          size: Dimensions.fontSizeDefault,
                                          color: Theme.of(context)
                                              .disabledColor
                                              .withOpacity(0.2),
                                        )
                                      ],
                                    ),
                                  ),

                                  // GestureDetector(
                                  //   onTap: () {
                                  //     showModalBottomSheet(
                                  //       context: context,
                                  //       isScrollControlled:
                                  //           true, // Allows the bottom sheet to adjust for the keyboard
                                  //       backgroundColor: Colors
                                  //           .transparent, // Transparent background for customization
                                  //       builder: (context) {
                                  //         return Container(
                                  //           height: MediaQuery.of(context)
                                  //                   .size
                                  //                   .height *
                                  //               0.36, // Fixed height for bottom sheet
                                  //           decoration: BoxDecoration(
                                  //             color: Colors.grey[
                                  //                 100], // Off-white background color
                                  //             borderRadius:
                                  //                 BorderRadius.vertical(
                                  //               top: Radius.circular(20),
                                  //             ),
                                  //           ),
                                  //           child: Padding(
                                  //             padding: EdgeInsets.only(
                                  //               left: 16.0,
                                  //               right: 16.0,
                                  //               top: 16.0,
                                  //               bottom: MediaQuery.of(context)
                                  //                   .viewInsets
                                  //                   .bottom, // Adjust for keyboard
                                  //             ),
                                  //             child: Column(
                                  //               crossAxisAlignment:
                                  //                   CrossAxisAlignment.start,
                                  //               children: [
                                  //                 Text(
                                  //                   'Edit Special Request',
                                  //                   style: poppinsSemiBold
                                  //                       .copyWith(
                                  //                     fontSize: Dimensions
                                  //                         .fontSizeLarge,
                                  //                   ),
                                  //                 ),
                                  //                 const SizedBox(height: 16),
                                  //                 Container(
                                  //                   height:
                                  //                       100, // Adjust the height of the input field as needed
                                  //                   padding:
                                  //                       const EdgeInsets.all(
                                  //                           8.0),
                                  //                   decoration: BoxDecoration(
                                  //                     color: Colors.grey[
                                  //                         200], // Light grey background color
                                  //                     borderRadius:
                                  //                         BorderRadius.circular(
                                  //                             10), // Rounded corners
                                  //                   ),
                                  //                   child: TextField(
                                  //                     maxLines:
                                  //                         null, // Allow multiple lines
                                  //                     expands:
                                  //                         true, // Make the field fill the container height
                                  //                     decoration:
                                  //                         InputDecoration(
                                  //                       hintText:
                                  //                           'Enter your special request',
                                  //                       border: InputBorder
                                  //                           .none, // Remove border
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //                 const Spacer(), // Push the button to the bottom
                                  //                 ElevatedButton(
                                  //                   onPressed: () {
                                  //                     // Handle saving or updating the special request
                                  //                     Navigator.pop(
                                  //                         context); // Close the bottom sheet
                                  //                   },
                                  //                   child: const Text(
                                  //                       'Save Reque'),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         );
                                  //       },
                                  //     );
                                  //   },
                                  //   child: Text(
                                  //     'Edit Special Request',
                                  //     style: poppinsSemiBold.copyWith(
                                  //       fontSize: Dimensions.fontSizeDefault,
                                  //       color: Theme.of(context)
                                  //           .disabledColor
                                  //           .withOpacity(0.2),
                                  //     ),
                                  //   ),
                                  // ),

                                  // GestureDetector(
                                  //   onTap: () {
                                  //     showModalBottomSheet(
                                  //       context: context,
                                  //       isScrollControlled:
                                  //           true, // Allows dynamic resizing for the keyboard
                                  //       backgroundColor: Colors
                                  //           .transparent, // Transparent background for customization
                                  //       builder: (context) {
                                  //         return DraggableScrollableSheet(
                                  //           expand: false,
                                  //           initialChildSize:
                                  //               0.4, // Initial size of the sheet (40% of the screen)
                                  //           minChildSize:
                                  //               0.3, // Minimum size of the sheet
                                  //           maxChildSize:
                                  //               0.8, // Maximum size of the sheet
                                  //           builder:
                                  //               (context, scrollController) {
                                  //             return Container(
                                  //               decoration: BoxDecoration(
                                  //                 color: Colors.grey[
                                  //                     100], // Off-white background color
                                  //                 borderRadius:
                                  //                     BorderRadius.vertical(
                                  //                   top: Radius.circular(20),
                                  //                 ),
                                  //               ),
                                  //               child: Padding(
                                  //                 padding: EdgeInsets.only(
                                  //                   left: 16.0,
                                  //                   right: 16.0,
                                  //                   top: 16.0,
                                  //                   bottom: MediaQuery.of(
                                  //                           context)
                                  //                       .viewInsets
                                  //                       .bottom, // Adjust for keyboard
                                  //                 ),
                                  //                 child: Column(
                                  //                   crossAxisAlignment:
                                  //                       CrossAxisAlignment
                                  //                           .start,
                                  //                   children: [
                                  //                     Text(
                                  //                       'Edit Special Request',
                                  //                       style: poppinsSemiBold
                                  //                           .copyWith(
                                  //                         fontSize: Dimensions
                                  //                             .fontSizeLarge,
                                  //                       ),
                                  //                     ),
                                  //                     const SizedBox(
                                  //                         height: 16),
                                  //                     Expanded(
                                  //                       child: Container(
                                  //                         padding:
                                  //                             const EdgeInsets
                                  //                                 .all(8.0),
                                  //                         decoration:
                                  //                             BoxDecoration(
                                  //                           color: Colors.grey[
                                  //                               200], // Light grey background color
                                  //                           borderRadius:
                                  //                               BorderRadius
                                  //                                   .circular(
                                  //                                       10), // Rounded corners
                                  //                         ),
                                  //                         child:
                                  //                             const TextField(
                                  //                           maxLines:
                                  //                               null, // Allow multiple lines
                                  //                           expands:
                                  //                               true, // Make the field take the full height
                                  //                           decoration:
                                  //                               InputDecoration(
                                  //                             hintText:
                                  //                                 'Enter your special request',
                                  //                             border: InputBorder
                                  //                                 .none, // Remove border
                                  //                           ),
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                     const SizedBox(
                                  //                         height: 16),
                                  //                     ElevatedButton(
                                  //                       onPressed: () {
                                  //                         // Handle saving or updating the special request
                                  //                         Navigator.pop(
                                  //                             context); // Close the bottom sheet
                                  //                       },
                                  //                       child: const Text(
                                  //                           'Save Request'),
                                  //                     ),
                                  //                   ],
                                  //                 ),
                                  //               ),
                                  //             );
                                  //           },
                                  //         );
                                  //       },
                                  //     );
                                  //   },
                                  //   child: Text(
                                  //     'Edit Special Request',
                                  //     style: poppinsSemiBold.copyWith(
                                  //       fontSize: Dimensions.fontSizeDefault,
                                  //       color: Theme.of(context)
                                  //           .disabledColor
                                  //           .withOpacity(0.2),
                                  //     ),
                                  //   ),
                                  // ),

                                  // GestureDetector(
                                  //   onTap: () {},
                                  //   child: Text(
                                  //     'Edit Special Request',
                                  //     style: poppinsSemiBold.copyWith(
                                  //         fontSize: Dimensions.fontSizeDefault,
                                  //         color: Theme.of(context)
                                  //             .disabledColor
                                  //             .withOpacity(0.2)),
                                  //   ),
                                  // ),
                                  const SizedBox(
                                    height: Dimensions.paddingSizeExtraSmall,
                                  ),

                                  // DiscountedPriceWidget(
                                  //   cart: cart,
                                  //   leadingText:
                                  //       '${getTranslated('unit', context)}: ',
                                  // ),

                                  // Row(children: [
                                  //   Text('${getTranslated('unit', context)}: ', style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                  //
                                  //   if((cart.discountedPrice ?? 0) < (cart.price ?? 0)) CustomDirectionalityWidget(child: Text(
                                  //     PriceConverterHelper.convertPrice(context, (cart.price ?? 0) * 1),
                                  //     style: poppinsRegular.copyWith(
                                  //       fontSize: Dimensions.fontSizeDefault,
                                  //       color: Theme.of(context).disabledColor,
                                  //       decoration: TextDecoration.lineThrough,
                                  //     ),
                                  //   )),
                                  //
                                  //   if((cart.discountedPrice ?? 0) < (cart.price ?? 0) ) const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  //
                                  //   CustomDirectionalityWidget(child: Text(
                                  //     PriceConverterHelper.convertPrice(context, (cart.discountedPrice ?? 0) * 1),
                                  //     style: poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                                  //     maxLines: 2,
                                  //   ))
                                  // ]),
                                  const SizedBox(
                                      height: Dimensions.paddingSizeExtraSmall),

                                  DiscountedPriceWidget(
                                    cart: cart,
                                    isUnitPrice: false,
                                    // leadingText:
                                    //     '${getTranslated('total', context)}: ',
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Expanded(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(cart.name ?? '',
                                              style: poppinsRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis),
                                          const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall),
                                          if (cart.product?.variations
                                                  ?.isNotEmpty ??
                                              false)
                                            Wrap(children: [
                                              Text(
                                                  '${getTranslated('variation', context)}: ',
                                                  style: poppinsRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeExtraSmall)),
                                              Text(variationText!,
                                                  style:
                                                      poppinsRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall,
                                                    color: Theme.of(context)
                                                        .disabledColor,
                                                  )),
                                            ]),
                                          DiscountedPriceWidget(
                                            cart: cart,
                                            leadingText:
                                                '${getTranslated('unit', context)}: ',
                                          ),
                                          const SizedBox(
                                              height: Dimensions
                                                  .paddingSizeExtraSmall),
                                        ]),
                                  ),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeLarge),
                                  Expanded(
                                    flex: 4,
                                    child: Row(children: [
                                      Text('${cart.capacity} ${cart.unit}',
                                          style: poppinsMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color:
                                                Theme.of(context).disabledColor,
                                          )),
                                      const SizedBox(
                                          width: Dimensions.paddingSizeDefault),
                                      DiscountedPriceWidget(
                                          cart: cart, isUnitPrice: false),
                                    ]),
                                  ),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeSmall),
                                ]),
                          ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: RotatedBox(
                        quarterTurns: ResponsiveHelper.isMobile() ? 0 : 1,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          GestureDetector(
                            onTap: () {
                              // if (cart.product!.maximumOrderQuantity == null ||
                              //     cart.quantity! <
                              //         cart.product!.maximumOrderQuantity!) {
                              //   if (cart.quantity! < cart.stock!) {
                              Provider.of<CouponProvider>(context,
                                      listen: false)
                                  .removeCouponData(false);
                              cartProvider.setCartQuantity(true, index,
                                  showMessage: true, context: context);
                              //  }
                              //else {
                              //     showCustomSnackBarHelper(
                              //         getTranslated('out_of_stock', context));
                              //   }
                              // } else {
                              //   showCustomSnackBarHelper(
                              //       '${getTranslated('you_can_add_max', context)} ${cart.product!.maximumOrderQuantity} ${getTranslated(cart.product!.maximumOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
                              // }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeSmall,
                                  vertical: ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.paddingSizeDefault
                                      : Dimensions.paddingSizeSmall),
                              child: Icon(Icons.add,
                                  size: 20,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          RotatedBox(
                            quarterTurns: ResponsiveHelper.isMobile() ? 0 : 3,
                            child: Text(
                              cart.quantity.toString(),
                              style: poppinsSemiBold.copyWith(
                                fontSize: Dimensions.fontSizeExtraLarge,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                          ),
                          RotatedBox(
                            quarterTurns: ResponsiveHelper.isMobile() ? 0 : 1,
                            child: (ResponsiveHelper.isDesktop(context) &&
                                    cart.quantity == 1)
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: Dimensions.paddingSizeSmall),
                                    child: IconButton(
                                      onPressed: () {
                                        cartProvider.removeItemFromCart(
                                            index, context);
                                        cartProvider.setExistData(null);
                                      },
                                      icon: const RotatedBox(
                                          quarterTurns: 2,
                                          child: Icon(CupertinoIcons.delete,
                                              color: Colors.red, size: 20)),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      Provider.of<CouponProvider>(context,
                                              listen: false)
                                          .removeCouponData(false);
                                      if (cart.quantity! > 1) {
                                        cartProvider.setCartQuantity(
                                            false, index,
                                            showMessage: true,
                                            context: context);
                                      } else if (cart.quantity == 1) {
                                        cartProvider.removeItemFromCart(
                                            index, context);
                                        cartProvider.setExistData(null);
                                      }
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: ResponsiveHelper
                                                  .isDesktop(context)
                                              ? Dimensions.paddingSizeDefault
                                              : Dimensions.paddingSizeSmall,
                                          vertical:
                                              Dimensions.paddingSizeSmall),
                                      child: Icon(Icons.remove,
                                          size: 20,
                                          color:
                                              Theme.of(context).disabledColor),
                                    ),
                                  ),
                          ),
                        ]),
                      ),
                    ),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }

  String? _getVariationValue() {
    String? variationText = '';
    if (cart.variation != null) {
      List<String> variationTypes = cart.variation?.type?.split('-') ?? [];
      if (variationTypes.length == cart.product?.choiceOptions?.length) {
        int index = 0;
        for (var choice in cart.product?.choiceOptions ?? []) {
          variationText =
              '$variationText${(index == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index]}';
          index = index + 1;
        }
      } else {
        variationText = cart.product?.variations?[0].type;
      }
    }

    return variationText;
  }
}

class _DiscountTag extends StatelessWidget {
  const _DiscountTag({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final CartModel cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      height: MediaQuery.of(context).size.height * 0.034,
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
              // cart.discount == 'percent'
              //     ? '-${product.discount} %'
              //:
              '-${PriceConverterHelper.convertPrice(context, cart.discount)}',
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
