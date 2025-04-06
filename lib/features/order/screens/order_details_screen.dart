import 'package:flutter/material.dart';

import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/features/order/domain/models/order_details_model.dart';

import 'package:flutter_grocery/features/order/domain/models/order_model.dart';

import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/order/providers/return_status_provider.dart';
import 'package:flutter_grocery/features/order/screens/oder_return_screen.dart';

import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/helper/date_converter_helper.dart';
import 'package:flutter_grocery/helper/order_helper.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';

import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  final String? phoneNumber;

  const OrderDetailsScreen({
    Key? key,
    required this.orderModel,
    required this.orderId,
    this.phoneNumber,
  }) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool showButton = true;

  bool returned = false;
  void _loadData(BuildContext context) async {
    Provider.of<ReturnStatusProvider>(context, listen: false).getReturnStatus();
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    orderProvider.trackOrder(
      widget.orderId.toString(),
      null,
      context,
      false,
      phoneNumber: widget.phoneNumber,
      isUpdate: false,
    );

    if (widget.orderModel == null) {
      await splashProvider.initConfig();
    }
    await orderProvider.initializeTimeSlot();
    orderProvider.getOrderDetails(
      orderID: widget.orderId.toString(),
      phoneNumber: widget.phoneNumber,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData(context);
  }

  late final splashProvider =
      Provider.of<SplashProvider>(context, listen: false);
  late final config = splashProvider.configModel;

  @override
  Widget build(BuildContext context) {
    print(
        '----return status ${Provider.of<ReturnStatusProvider>(context, listen: false).status}');
    var querySize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorResources.scaffoldGrey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.chevron_left,
            size: 30,
          ),
        ),
        centerTitle: true,
        title: Text(
          getTranslated('order_details', context),
          style: poppinsSemiBold.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          double deliveryCharge = OrderHelper.getDeliveryCharge(
              orderModel: orderProvider.trackModel);
          double itemsPrice = OrderHelper.getOrderDetailsValue(
            orderDetailsList: orderProvider.orderDetails,
            type: OrderValue.itemPrice,
          );
          double deliveryFee = OrderHelper.getOrderDetailsValue(
            orderDetailsList: orderProvider.orderDetails,
            type: OrderValue.deliveryFee,
          );
          double walletUsed = OrderHelper.getOrderDetailsValue(
            orderDetailsList: orderProvider.orderDetails,
            type: OrderValue.walletUsed,
          );
          double couponDiscount = OrderHelper.getOrderDetailsValue(
            orderDetailsList: orderProvider.orderDetails,
            type: OrderValue.couponDiscount,
          );
          double discount = OrderHelper.getOrderDetailsValue(
            orderDetailsList: orderProvider.orderDetails,
            type: OrderValue.discount,
          );
          double extraDiscount = OrderHelper.getExtraDiscount(
              trackOrder: orderProvider.trackModel);
          double tax = OrderHelper.getOrderDetailsValue(
            orderDetailsList: orderProvider.orderDetails,
            type: OrderValue.tax,
          );
          bool isVatInclude = OrderHelper.isVatTaxInclude(
              orderDetailsList: orderProvider.orderDetails);
          double subTotal = OrderHelper.getSubTotalAmount(
            itemsPrice: itemsPrice,
            tax: tax,
            isVatInclude: isVatInclude,
          );
          double total = OrderHelper.getTotalOrderAmount(
              subTotal: subTotal,
              discount: discount,
              extraDiscount: extraDiscount,
              deliveryCharge: deliveryCharge,
              couponDiscount: couponDiscount,
              // couponDiscount: orderProvider.trackModel?.couponDiscountAmount,
              walletUsed: walletUsed);

          return (orderProvider.orderDetails == null ||
                  orderProvider.trackModel == null)
              ? Center(
                  child:
                      CustomLoaderWidget(color: Theme.of(context).primaryColor))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 32,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeLarge,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                orderProvider.orderDetails!.length,
                                (index) {
                                  print(
                                      '-------${index}------${orderProvider.orderDetails![index].isReturned!}');
                                  // if (orderProvider
                                  //         .orderDetails![index].isReturned !=
                                  //     0) {
                                  //   showButton = false;
                                  //   // return; // Exit early if any value is different from 0
                                  // }
                                  String _getOrderStatusText(int status) {
                                    switch (status) {
                                      case 1:
                                        return 'Under Review';
                                      case 2:
                                        return 'Return By Replacement';
                                      case 3:
                                        return 'Return By Wallet';
                                      case 4:
                                        return 'Return By Cash';
                                      case 5:
                                        return 'Declined';
                                      default:
                                        return ''; // If status doesn't match any of the cases, return an empty string
                                    }
                                  }
                                  // String _getOrderStatusText(int status) {
                                  //   switch (status) {
                                  //     case 1:
                                  //       return 'Returned';
                                  //     case 2:
                                  //       return 'Credited to wallet';
                                  //     case 3:
                                  //       return 'Declined';
                                  //     case 4:
                                  //       return 'Return By Cash';
                                  //     default:
                                  //       return ''; // If status doesn't match any of the cases, return an empty string
                                  //   }
                                  // }

                                  return Padding(
                                    padding: EdgeInsets.only(
                                        top: index == 0 ? 0 : 16.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: const Color(0xFFF9F9F9),
                                      ),
                                      child: Row(
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions
                                                            .radiusSizeTen),
                                                child: CustomImageWidget(
                                                  placeholder:
                                                      Images.placeHolder,
                                                  image:
                                                      '${splashProvider.baseUrls!.productImageUrl}/${orderProvider.orderDetails![index].productDetails!.image!.isNotEmpty ? orderProvider.orderDetails![index].productDetails!.image![0] : ''}',
                                                  height: 80,
                                                  width: 80,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              orderProvider
                                                          .orderDetails![index]
                                                          .productDetails
                                                          ?.discount !=
                                                      0.0
                                                  ? Positioned(
                                                      top:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.01,
                                                      left:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.01,
                                                      child: _DiscountTag(
                                                          productDetails:
                                                              orderProvider
                                                                  .orderDetails![
                                                                      index]
                                                                  .productDetails),
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${orderProvider.orderDetails![index].productDetails?.name ?? ""} x ${orderProvider.orderDetails![index].quantity ?? ""}",
                                                  style: poppinsMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeLarge),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                if (orderProvider
                                                        .orderDetails![index]
                                                        .remarks !=
                                                    null)
                                                  Text(
                                                    "${orderProvider.orderDetails![index].remarks}",
                                                    style:
                                                        poppinsMedium.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "${orderProvider.orderDetails![index].productDetails?.approximateWeight ?? ""} ${orderProvider.orderDetails![index].productDetails?.approximateUom ?? ""} (Approx)",
                                                  style: poppinsMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeLarge),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      PriceConverterHelper.convertPrice(
                                                          context,
                                                          calculateFinalPrice(
                                                              orderProvider
                                                                  .orderDetails![
                                                                      index]
                                                                  .productDetails,
                                                              orderProvider
                                                                      .orderDetails![
                                                                          index]
                                                                      .quantity ??
                                                                  1)),
                                                      style:
                                                          poppinsBold.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeLarge,
                                                      ),
                                                    ),
                                                    // Text(
                                                    //   PriceConverterHelper
                                                    //       .convertPrice(
                                                    //           context,
                                                    //           orderProvider
                                                    //               .orderDetails![
                                                    //                   index]
                                                    //               .productDetails
                                                    //               ?.price),
                                                    //   //"${orderProvider.orderDetails![index].price ?? ""} ${config?.currencySymbol ?? ""}",
                                                    //   style:
                                                    //       poppinsBold.copyWith(
                                                    //     fontSize: Dimensions
                                                    //         .fontSizeLarge,
                                                    //   ),
                                                    // ),
                                                    const Spacer(),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .white, // Set the background color to white
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                8), // Adjust the radius as needed
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical:
                                                              4), // Add padding to the container
                                                      child: Text(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        _getOrderStatusText(
                                                            orderProvider
                                                                .orderDetails![
                                                                    index]
                                                                .isReturned!),
                                                        style: TextStyle(
                                                          fontSize:
                                                              querySize.width *
                                                                  0.028,
                                                          color: Colors
                                                              .red, // Set text color to red for negative statuses
                                                        ),
                                                      ),
                                                    ),
                                                    // orderProvider
                                                    //             .orderDetails![
                                                    //                 index]
                                                    //             .isReturned ==
                                                    //         1
                                                    //     ? Container(
                                                    //         decoration:
                                                    //             BoxDecoration(
                                                    //           color: Colors
                                                    //               .white, // Set the background color to white
                                                    //           borderRadius:
                                                    //               BorderRadius
                                                    //                   .circular(
                                                    //                       8), // Adjust the radius as needed
                                                    //         ),
                                                    //         padding:
                                                    //             const EdgeInsets
                                                    //                 .symmetric(
                                                    //                 horizontal:
                                                    //                     8,
                                                    //                 vertical:
                                                    //                     4), // Add padding to the container
                                                    //         child: const Text(
                                                    //           'Returned',
                                                    //           style: TextStyle(
                                                    //             fontSize: 13,
                                                    //             color: Colors
                                                    //                 .red, // Set text color to red
                                                    //           ),
                                                    //         ),
                                                    //       )
                                                    //     : SizedBox(),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.02,
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 65,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/image/order_details_strip.png'),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 32,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeLarge,
                            ),
                            child: Column(
                              children: [
                                orderSummaryTile(context, 'order_id',
                                    orderProvider.trackModel!.id.toString()),
                                if (orderProvider.trackModel!.couponCode !=
                                    null)
                                  orderSummaryTile(
                                      context,
                                      'Promo Code',
                                      orderProvider.trackModel!.couponCode
                                          .toString()),
                                if (orderProvider.trackModel!.createdAt != null)
                                  orderSummaryTile(
                                      context,
                                      'ordered_at',
                                      DateConverterHelper
                                          .isoStringToOrderDetailsDateTime(
                                              orderProvider
                                                  .trackModel!.createdAt
                                                  .toString())),
                                if (orderProvider.trackModel!.deliveryDate !=
                                    null)
                                  orderSummaryTile(
                                      context,
                                      'delivery_date',
                                      DateConverterHelper
                                          .isoStringToOrderDetailsDateTime(
                                              orderProvider
                                                  .trackModel!.deliveryDate
                                                  .toString())),
                                if (orderProvider.trackModel!.paymentMethod !=
                                    null)
                                  orderSummaryTile(
                                      context,
                                      'payment_method',
                                      getTranslated(
                                          orderProvider
                                              .trackModel!.paymentMethod
                                              .toString(),
                                          context)),
                                if (orderProvider.trackModel!.paymentStatus !=
                                    null)
                                  orderSummaryTile(
                                      context,
                                      'Payment Status',
                                      getTranslated(
                                          orderProvider
                                              .trackModel!.paymentStatus
                                              .toString(),
                                          context)),
                                const Divider(),
                                const SizedBox(height: 16),
                                orderSummaryTile(
                                    context,
                                    'Actual Amount',
                                    subTotal.toStringAsFixed(2).toString(),
                                    true),
                                orderSummaryTile(
                                    context,
                                    'Product Discount',
                                    "-${discount.toStringAsFixed(2)}",
                                    true,
                                    true),
                                orderSummaryTile(
                                    context,
                                    'coupon_discount',
                                    "-${couponDiscount.toStringAsFixed(2)}",
                                    true,
                                    true),
                                orderSummaryTile(
                                    context,
                                    'Wallet Amount Used',
                                    "-${walletUsed.toStringAsFixed(2)}",
                                    true,
                                    true),

                                orderSummaryTile(
                                    context,
                                    'delivery_fee',
                                    deliveryCharge
                                        .toStringAsFixed(2)
                                        .toString(),
                                    true),
                                // orderSummaryTile(
                                //     context, 'Walle', "-$discount", true, true),
                                // orderSummaryTile(context, 'Subtotal',
                                //     subTotal.toString(), true),
                                // if (discount != 0)
                                //   orderSummaryTile(context, 'Discount',
                                //       "-$discount", true, true),
                                // if (tax != 0.0)
                                //   orderSummaryTile(
                                //       context,
                                //       'Tax',
                                //       "$tax ${isVatInclude ? ' (Included)' : ''}",
                                //       true),
                                // orderSummaryTile(context, 'Delivery Fee',
                                //     deliveryCharge.toString(), true),
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(getTranslated('Sub Total', context),
                                          style: poppinsBold.copyWith(
                                              fontSize: Dimensions
                                                  .fontSizeExtraLarge)),
                                      Text(
                                          PriceConverterHelper.convertPrice(
                                              context, total),
                                          style: poppinsBold.copyWith(
                                              fontSize: Dimensions
                                                  .fontSizeExtraLarge))
                                      // Text(
                                      //     "${total.toStringAsFixed(2)} ${config!.currencySymbol ?? ""}",
                                      //     style: poppinsBold.copyWith(
                                      //         fontSize: Dimensions
                                      //             .fontSizeExtraLarge)),
                                    ],
                                  ),
                                ),
                                if (orderProvider.trackModel!.orderStatus ==
                                        'delivered' &&
                                    //  widget.orderModel!.isReturnRequested == 0 &&
                                    orderProvider.trackModel!.isReturned == 0 &&
                                    Provider.of<ReturnStatusProvider>(context,
                                                listen: false)
                                            .status ==
                                        '1')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24),
                                    child: CustomButtonWidget(
                                      buttonText: 'Return Order / Refund',
                                      onPressed: () async {
                                        // await Provider.of<ReturnStatusProvider>(
                                        //         context,
                                        //         listen: false)
                                        //     .getReturnStatus();
                                        // if (widget.orderModel!
                                        //             .isReturnRequested !=
                                        //         0 &&
                                        //     Provider.of<ReturnStatusProvider>(
                                        //                 context,
                                        //                 listen: false)
                                        //             .status !=
                                        //         '1') {
                                        //   showCustomSnackBarHelper(
                                        //       'Already returned',
                                        //       isError: false);
                                        // }
                                        print(
                                            '----return status${Provider.of<ReturnStatusProvider>(context, listen: false).status}');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OrderReturnScreen(
                                              orderModel: widget.orderModel,
                                              orderId: widget.orderId,
                                              phoneNumber: widget.phoneNumber,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }

  orderSummaryTile(BuildContext context, String title, String data,
      [bool isPrice = false, bool isRed = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(getTranslated(title, context), style: poppinsSemiBold),
          isPrice
              ? Text(
                  PriceConverterHelper.convertPrice(
                      context, double.parse(data)),
                  style: poppinsSemiBold.copyWith(
                      color: isRed ? Colors.red : null))
              : Text(
                  data + (!isPrice ? "" : " ${config!.currencySymbol ?? ""}"),
                  style: poppinsSemiBold.copyWith(
                      color: isRed ? Colors.red : null),
                ),
        ],
      ),
    );
  }
}

double calculateFinalPrice(ProductDetails? productDetails, int quantity) {
  if (productDetails == null) return 0.0;

  double basePrice = productDetails.price ?? 0.0;
  double discount = productDetails.discount ?? 0.0;
  String? discountType = productDetails.discountType;

  // Calculate price after discount
  double priceAfterDiscount;
  if (discount > 0) {
    if (discountType == 'percent') {
      // Apply percentage discount
      double discountAmount = (basePrice * discount) / 100;
      priceAfterDiscount = basePrice - discountAmount;
    } else {
      // Apply fixed amount discount
      priceAfterDiscount = basePrice - discount;
    }
  } else {
    priceAfterDiscount = basePrice;
  }

  // Multiply by quantity
  return priceAfterDiscount * quantity;
}

class _DiscountTag extends StatelessWidget {
  const _DiscountTag({
    Key? key,
    required this.productDetails,
  }) : super(key: key);

  final ProductDetails? productDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      height: MediaQuery.of(context).size.height * 0.03,
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
              productDetails!.discountType == 'percent'
                  ? '-${productDetails!.discount!} %'
                  : '-${PriceConverterHelper.convertPrice(context, productDetails!.discount!)}',
              style: poppinsRegular.copyWith(
                  fontSize: MediaQuery.of(context).size.width * 0.022,
                  color: Theme.of(context).cardColor),
            ),
          ),
        ],
      ),
    );
  }
}

// class OrderDetailsScreen extends StatefulWidget {
//   final OrderModel? orderModel;
//   final int? orderId;
//   final String? phoneNumber;

//   const OrderDetailsScreen({
//     Key? key,
//     required this.orderModel,
//     required this.orderId,
//     this.phoneNumber,
//   }) : super(key: key);

//   @override
//   State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
// }

// class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
//   void _loadData(BuildContext context) async {
//     final splashProvider = Provider.of<SplashProvider>(context, listen: false);
//     final orderProvider = Provider.of<OrderProvider>(context, listen: false);

//     orderProvider.trackOrder(
//       widget.orderId.toString(),
//       null,
//       context,
//       false,
//       phoneNumber: widget.phoneNumber,
//       isUpdate: false,
//     );

//     if (widget.orderModel == null) {
//       await splashProvider.initConfig();
//     }
//     await orderProvider.initializeTimeSlot();
//     orderProvider.getOrderDetails(
//       orderID: widget.orderId.toString(),
//       phoneNumber: widget.phoneNumber,
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadData(context);
//   }

//   late final splashProvider =
//       Provider.of<SplashProvider>(context, listen: false);
//   late final config = splashProvider.configModel;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorResources.scaffoldGrey,
//       appBar: (ResponsiveHelper.isDesktop(context)
//           ? const PreferredSize(
//               preferredSize: Size.fromHeight(120),
//               child: WebAppBarWidget(),
//             )
//           : AppBar(
//               backgroundColor: Theme.of(context).cardColor,
//               leading: GestureDetector(
//                 onTap: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Icon(
//                   Icons.chevron_left,
//                   size: 30,
//                 ),
//               ),
//               centerTitle: true,
//               scrolledUnderElevation: 0,
//               title: Text(
//                 getTranslated('order_details', context),
//                 style: poppinsSemiBold.copyWith(
//                   fontSize: Dimensions.fontSizeExtraLarge,
//                   color: Theme.of(context).textTheme.bodyLarge!.color,
//                 ),
//               ),
//             )) as PreferredSizeWidget?,
//       body: Consumer<OrderProvider>(
//         builder: (context, orderProvider, _) {
//           double deliveryCharge = OrderHelper.getDeliveryCharge(
//               orderModel: orderProvider.trackModel);
//           double itemsPrice = OrderHelper.getOrderDetailsValue(
//             orderDetailsList: orderProvider.orderDetails,
//             type: OrderValue.itemPrice,
//           );
//           double discount = OrderHelper.getOrderDetailsValue(
//             orderDetailsList: orderProvider.orderDetails,
//             type: OrderValue.discount,
//           );
//           double extraDiscount = OrderHelper.getExtraDiscount(
//               trackOrder: orderProvider.trackModel);
//           double tax = OrderHelper.getOrderDetailsValue(
//             orderDetailsList: orderProvider.orderDetails,
//             type: OrderValue.tax,
//           );
//           bool isVatInclude = OrderHelper.isVatTaxInclude(
//               orderDetailsList: orderProvider.orderDetails);
//           double subTotal = OrderHelper.getSubTotalAmount(
//             itemsPrice: itemsPrice,
//             tax: tax,
//             isVatInclude: isVatInclude,
//           );
//           double total = OrderHelper.getTotalOrderAmount(
//             subTotal: subTotal,
//             discount: discount,
//             extraDiscount: extraDiscount,
//             deliveryCharge: deliveryCharge,
//             couponDiscount: orderProvider.trackModel?.couponDiscountAmount,
//           );

//           return (orderProvider.orderDetails == null ||
//                   orderProvider.trackModel == null)
//               ? Center(
//                   child:
//                       CustomLoaderWidget(color: Theme.of(context).primaryColor))
//               : orderProvider.orderDetails!.isNotEmpty
//                   ? Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(top: 16.0),
//                           child: Container(
//                             width: MediaQuery.of(context).size.width - 32,
//                             decoration: const BoxDecoration(
//                               borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(12),
//                                 topRight: Radius.circular(12),
//                               ),
//                               color: Colors.white,
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: Dimensions.paddingSizeDefault,
//                               vertical: Dimensions.paddingSizeLarge,
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: List.generate(
//                                 orderProvider.orderDetails!.length,
//                                 (index) => Padding(
//                                   padding: EdgeInsets.only(
//                                       top: index == 0 ? 0 : 16.0),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(12),
//                                       color: const Color(0xFFF9F9F9),
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         ClipRRect(
//                                           borderRadius: BorderRadius.circular(
//                                               Dimensions.radiusSizeTen),
//                                           child: CustomImageWidget(
//                                             placeholder: Images.placeHolder,
//                                             image:
//                                                 '${splashProvider.baseUrls!.productImageUrl}/${orderProvider.orderDetails![index].productDetails!.image!.isNotEmpty ? orderProvider.orderDetails![index].productDetails!.image![0] : ''}',
//                                             height: 80,
//                                             width: 80,
//                                             fit: BoxFit.cover,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 16),
//                                         Flexible(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Flexible(
//                                                     child: Text(
//                                                       orderProvider
//                                                               .orderDetails![
//                                                                   index]
//                                                               .productDetails
//                                                               ?.name ??
//                                                           "",
//                                                       style: poppinsMedium.copyWith(
//                                                           fontSize: Dimensions
//                                                               .fontSizeLarge),
//                                                       maxLines: 2,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                   ),
//                                                   Flexible(
//                                                     child: Text(
//                                                       " x ${orderProvider.orderDetails![index].quantity ?? ""}",
//                                                       style: poppinsMedium,
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.clip,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               const SizedBox(height: 4),
//                                               Row(
//                                                 children: [
//                                                   Flexible(
//                                                     child: Text(
//                                                       "${orderProvider.orderDetails![index].price ?? ""}",
//                                                       style:
//                                                           poppinsBold.copyWith(
//                                                         fontSize: Dimensions
//                                                             .fontSizeExtraLarge,
//                                                       ),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.clip,
//                                                     ),
//                                                   ),
//                                                   Flexible(
//                                                     child: Text(
//                                                       config?.currencySymbol ??
//                                                           "",
//                                                       style:
//                                                           poppinsBold.copyWith(
//                                                         fontSize: Dimensions
//                                                             .fontSizeExtraLarge,
//                                                       ),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.clip,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                           child: Container(
//                             height: 65,
//                             width: double.infinity,
//                             decoration: const BoxDecoration(
//                               image: DecorationImage(
//                                 image: AssetImage(
//                                     'assets/image/order_details_strip.png'),
//                                 fit: BoxFit.fitWidth,
//                               ),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(bottom: 16.0),
//                           child: Container(
//                             width: MediaQuery.of(context).size.width - 32,
//                             decoration: const BoxDecoration(
//                               borderRadius: BorderRadius.only(
//                                 bottomLeft: Radius.circular(12),
//                                 bottomRight: Radius.circular(12),
//                               ),
//                               color: Colors.white,
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: Dimensions.paddingSizeDefault,
//                               vertical: Dimensions.paddingSizeLarge,
//                             ),
//                             child: Column(
//                               children: [
//                                 orderSummaryTile(
//                                   context,
//                                   getTranslated('order_id', context),
//                                   orderProvider.trackModel!.id.toString(),
//                                 ),
//                                 if (orderProvider.trackModel!.couponCode !=
//                                     null)
//                                   orderSummaryTile(
//                                     context,
//                                     getTranslated('Promo Code', context),
//                                     orderProvider.trackModel!.couponCode
//                                         .toString(),
//                                   ),
//                                 if (orderProvider.trackModel!.createdAt != null)
//                                   orderSummaryTile(
//                                     context,
//                                     getTranslated('ordered_at', context),
//                                     DateConverterHelper
//                                         .isoStringToOrderDetailsDateTime(
//                                             orderProvider.trackModel!.createdAt
//                                                 .toString()),
//                                   ),
//                                 if (orderProvider.trackModel!.deliveryDate !=
//                                     null)
//                                   orderSummaryTile(
//                                     context,
//                                     getTranslated('delivery', context),
//                                     DateConverterHelper
//                                         .isoStringToOrderDetailsDateTime(
//                                             orderProvider
//                                                 .trackModel!.deliveryDate
//                                                 .toString()),
//                                   ),
//                                 if (orderProvider.trackModel!.paymentMethod !=
//                                     null)
//                                   orderSummaryTile(
//                                     context,
//                                     getTranslated('payment_method', context),
//                                     getTranslated(
//                                         orderProvider.trackModel!.paymentMethod
//                                             .toString(),
//                                         context),
//                                   ),
//                                 if (orderProvider.trackModel!.paymentStatus !=
//                                     null)
//                                   orderSummaryTile(
//                                     context,
//                                     getTranslated('PAYMENT', context),
//                                     getTranslated(
//                                         orderProvider.trackModel!.paymentStatus
//                                             .toString(),
//                                         context),
//                                   ),
//                                 const Divider(),
//                                 const SizedBox(height: 16),
//                                 orderSummaryTile(
//                                   context,
//                                   getTranslated('subtotal', context),
//                                   subTotal.toString(),
//                                   true,
//                                 ),
//                                 if (discount != 0)
//                                   orderSummaryTile(
//                                     context,
//                                     getTranslated('discount', context),
//                                     "-$discount",
//                                     true,
//                                     true,
//                                   ),
//                                 if (tax != 0.0)
//                                   orderSummaryTile(
//                                     context,
//                                     getTranslated('tax', context),
//                                     "$tax ${isVatInclude ? '(${getTranslated('include', context)})' : ''}",
//                                     true,
//                                   ),
//                                 orderSummaryTile(
//                                   context,
//                                   getTranslated('delivery_fee', context),
//                                   deliveryCharge.toString(),
//                                   true,
//                                 ),
//                                 const Divider(),
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 8.0),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         getTranslated("total", context),
//                                         style: poppinsBold.copyWith(
//                                             fontSize:
//                                                 Dimensions.fontSizeExtraLarge),
//                                       ),
//                                       Text(
//                                         "$total ${config!.currencySymbol ?? ""}",
//                                         style: poppinsBold.copyWith(
//                                             fontSize:
//                                                 Dimensions.fontSizeExtraLarge),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                                 if (orderProvider.trackModel!.orderStatus ==
//                                     'delivered')
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 24),
//                                     child: CustomButtonWidget(
//                                       buttonText: 'Order Return / Refund',
//                                       onPressed: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 OrderReturnScreen(
//                                               orderModel: widget.orderModel,
//                                               orderId: widget.orderId,
//                                               phoneNumber: widget.phoneNumber,
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     )
//                   : NoDataWidget(
//                       isShowButton: true,
//                       image: Images.box,
//                       title: 'order_not_found'.tr,
//                     );
//         },
//       ),
//     );
//   }

//   orderSummaryTile(BuildContext context, String title, String data,
//       [bool isPrice = false, bool isRed = false]) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: poppinsSemiBold),
//           Text(
//             data + (!isPrice ? "" : " ${config!.currencySymbol ?? ""}"),
//             style: poppinsSemiBold.copyWith(color: isRed ? Colors.red : null),
//           ),
//         ],
//       ),
//     );
//   }
// }
// class OrderDetailsScreen extends StatefulWidget {
//   final OrderModel? orderModel;
//   final int? orderId;
//   final String? phoneNumber;

//   const OrderDetailsScreen(
//       {Key? key,
//       required this.orderModel,
//       required this.orderId,
//       this.phoneNumber})
//       : super(key: key);

//   @override
//   State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
// }

// class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
//   void _loadData(BuildContext context) async {
//     final splashProvider = Provider.of<SplashProvider>(context, listen: false);
//     final orderProvider = Provider.of<OrderProvider>(context, listen: false);

//     orderProvider.trackOrder(widget.orderId.toString(), null, context, false,
//         phoneNumber: widget.phoneNumber, isUpdate: false);

//     if (widget.orderModel == null) {
//       await splashProvider.initConfig();
//     }
//     await orderProvider.initializeTimeSlot();
//     orderProvider.getOrderDetails(
//         orderID: widget.orderId.toString(), phoneNumber: widget.phoneNumber);
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadData(context);
//   }

//   late final splashProvider =
//       Provider.of<SplashProvider>(context, listen: false);
//   late final config = splashProvider.configModel;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorResources.scaffoldGrey,
//       appBar: (ResponsiveHelper.isDesktop(context)
//           ? const PreferredSize(
//               preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
//           : AppBar(
//               backgroundColor: Theme.of(context).cardColor,
//               leading: GestureDetector(
//                 onTap: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Icon(
//                   Icons.chevron_left,
//                   size: 30,
//                 ),
//               ),
//               centerTitle: true,
//               scrolledUnderElevation: 0,
//               title: Text(
//                 getTranslated('order_details', context),
//                 style: poppinsSemiBold.copyWith(
//                   fontSize: Dimensions.fontSizeExtraLarge,
//                   color: Theme.of(context).textTheme.bodyLarge!.color,
//                 ),
//               ),
//             )) as PreferredSizeWidget?,
//       body: Consumer<OrderProvider>(builder: (context, orderProvider, _) {
//         double deliveryCharge =
//             OrderHelper.getDeliveryCharge(orderModel: orderProvider.trackModel);
//         double itemsPrice = OrderHelper.getOrderDetailsValue(
//             orderDetailsList: orderProvider.orderDetails,
//             type: OrderValue.itemPrice);
//         double discount = OrderHelper.getOrderDetailsValue(
//             orderDetailsList: orderProvider.orderDetails,
//             type: OrderValue.discount);
//         double extraDiscount =
//             OrderHelper.getExtraDiscount(trackOrder: orderProvider.trackModel);
//         double tax = OrderHelper.getOrderDetailsValue(
//             orderDetailsList: orderProvider.orderDetails, type: OrderValue.tax);
//         bool isVatInclude = OrderHelper.isVatTaxInclude(
//             orderDetailsList: orderProvider.orderDetails);
//         TimeSlotModel? timeSlot = OrderHelper.getTimeSlot(
//             timeSlotList: orderProvider.allTimeSlots,
//             timeSlotId: orderProvider.trackModel?.timeSlotId);

//         double subTotal = OrderHelper.getSubTotalAmount(
//             itemsPrice: itemsPrice, tax: tax, isVatInclude: isVatInclude);

//         double total = OrderHelper.getTotalOrderAmount(
//           subTotal: subTotal,
//           discount: discount,
//           extraDiscount: extraDiscount,
//           deliveryCharge: deliveryCharge,
//           couponDiscount: orderProvider.trackModel?.couponDiscountAmount,
//         );

//         return (orderProvider.orderDetails == null ||
//                 orderProvider.trackModel == null)
//             ? Center(
//                 child:
//                     CustomLoaderWidget(color: Theme.of(context).primaryColor))
//             : orderProvider.orderDetails!.isNotEmpty
//                 ? Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(top: 16.0),
//                         child: Container(
//                           width: MediaQuery.of(context).size.width - 32,
//                           decoration: const BoxDecoration(
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(12),
//                               topRight: Radius.circular(12),
//                             ),
//                             color: Colors.white,
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: Dimensions.paddingSizeDefault,
//                             vertical: Dimensions.paddingSizeLarge,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: List.generate(
//                               orderProvider.orderDetails!.length,
//                               (index) => Padding(
//                                 padding:
//                                     EdgeInsets.only(top: index == 0 ? 0 : 16.0),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(12),
//                                     color: const Color(0xFFF9F9F9),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(
//                                             Dimensions.radiusSizeTen),
//                                         child: CustomImageWidget(
//                                           placeholder: Images.placeHolder,
//                                           image:
//                                               '${splashProvider.baseUrls!.productImageUrl}/'
//                                               '${orderProvider.orderDetails![index].productDetails!.image!.isNotEmpty ? orderProvider.orderDetails![index].productDetails!.image![0] : ''}',
//                                           height: 80,
//                                           width: 80,
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 16),
//                                       Flexible(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Flexible(
//                                                   child: Text(
//                                                     orderProvider
//                                                             .orderDetails![
//                                                                 index]
//                                                             .productDetails
//                                                             ?.name ??
//                                                         "",
//                                                     style:
//                                                         poppinsMedium.copyWith(
//                                                             fontSize: Dimensions
//                                                                 .fontSizeLarge),
//                                                     maxLines: 2,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                   ),
//                                                 ),
//                                                 Flexible(
//                                                   child: Text(
//                                                     " x ${orderProvider.orderDetails![index].quantity ?? ""}",
//                                                     style: poppinsMedium,
//                                                     maxLines: 1,
//                                                     overflow: TextOverflow.clip,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Row(
//                                               children: [
//                                                 Flexible(
//                                                   child: Text(
//                                                     "${orderProvider.orderDetails![index].price ?? ""}",
//                                                     style: poppinsBold.copyWith(
//                                                       fontSize: Dimensions
//                                                           .fontSizeExtraLarge,
//                                                     ),
//                                                     maxLines: 1,
//                                                     overflow: TextOverflow.clip,
//                                                   ),
//                                                 ),
//                                                 Flexible(
//                                                   child: Text(
//                                                     config?.currencySymbol ??
//                                                         "",
//                                                     style: poppinsBold.copyWith(
//                                                       fontSize: Dimensions
//                                                           .fontSizeExtraLarge,
//                                                     ),
//                                                     maxLines: 1,
//                                                     overflow: TextOverflow.clip,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                         child: Container(
//                           height: 65,
//                           width: double.infinity,
//                           decoration: const BoxDecoration(
//                             image: DecorationImage(
//                               image: AssetImage(
//                                 'assets/image/order_details_strip.png',
//                               ),
//                               fit: BoxFit.fitWidth,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 16.0),
//                         child: Container(
//                           width: MediaQuery.of(context).size.width - 32,
//                           decoration: const BoxDecoration(
//                             borderRadius: BorderRadius.only(
//                               bottomLeft: Radius.circular(12),
//                               bottomRight: Radius.circular(12),
//                             ),
//                             color: Colors.white,
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: Dimensions.paddingSizeDefault,
//                             vertical: Dimensions.paddingSizeLarge,
//                           ),
//                           child: Column(
//                             children: [
//                               orderSummaryTile(
//                                 context,
//                                 getTranslated(
//                                   'order_id',
//                                   context,
//                                 ),
//                                 orderProvider.trackModel!.id.toString(),
//                               ),
//                               if (orderProvider.trackModel!.couponCode != null)
//                                 orderSummaryTile(
//                                   context,
//                                   getTranslated(
//                                     'Promo Code',
//                                     context,
//                                   ),
//                                   orderProvider.trackModel!.couponCode
//                                       .toString(),
//                                 ),
//                               if (orderProvider.trackModel!.createdAt != null)
//                                 orderSummaryTile(
//                                   context,
//                                   getTranslated(
//                                     'ordered_at',
//                                     context,
//                                   ),
//                                   DateConverterHelper
//                                       .isoStringToOrderDetailsDateTime(
//                                     orderProvider.trackModel!.createdAt
//                                         .toString(),
//                                   ),
//                                 ),
//                               if (orderProvider.trackModel!.deliveryDate !=
//                                   null)
//                                 orderSummaryTile(
//                                   context,
//                                   getTranslated(
//                                     'delivery',
//                                     context,
//                                   ),
//                                   DateConverterHelper
//                                       .isoStringToOrderDetailsDateTime(
//                                     orderProvider.trackModel!.deliveryDate
//                                         .toString(),
//                                   ),
//                                 ),
//                               if (orderProvider.trackModel!.paymentMethod !=
//                                   null)
//                                 orderSummaryTile(
//                                     context,
//                                     getTranslated(
//                                       'payment_method',
//                                       context,
//                                     ),
//                                     getTranslated(
//                                         orderProvider.trackModel!.paymentMethod
//                                             .toString(),
//                                         context)),
//                               if (orderProvider.trackModel!.paymentStatus !=
//                                   null)
//                                 orderSummaryTile(
//                                   context,
//                                   getTranslated(
//                                     'PAYMENT',
//                                     context,
//                                   ),
//                                   getTranslated(
//                                       orderProvider.trackModel!.paymentStatus
//                                           .toString(),
//                                       context),
//                                 ),
//                               const Divider(),
//                               const SizedBox(height: 16),
//                               orderSummaryTile(
//                                 context,
//                                 getTranslated(
//                                   'subtotal',
//                                   context,
//                                 ),
//                                 getTranslated(subTotal.toString(), context),
//                                 true,
//                               ),
//                               if (discount != 0)
//                                 orderSummaryTile(
//                                   context,
//                                   getTranslated(
//                                     'discount',
//                                     context,
//                                   ),
//                                   "-${getTranslated(discount.toString(), context)}",
//                                   true,
//                                   true,
//                                 ),
//                               if (tax != 0.0)
//                                 orderSummaryTile(
//                                   context,
//                                   getTranslated(
//                                     'tax',
//                                     context,
//                                   ),
//                                   getTranslated(tax.toString(), context) +
//                                       (isVatInclude
//                                           ? " (${getTranslated('include', context)})"
//                                           : ""),
//                                   true,
//                                 ),
//                               orderSummaryTile(
//                                 context,
//                                 getTranslated(
//                                   'delivery_fee',
//                                   context,
//                                 ),
//                                 deliveryCharge.toString(),
//                                 true,
//                               ),
//                               const Divider(),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 8.0),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       getTranslated("total", context),
//                                       style: poppinsBold.copyWith(
//                                         fontSize: Dimensions.fontSizeExtraLarge,
//                                       ),
//                                     ),
//                                     Text(
//                                       "$total ${config!.currencySymbol ?? ""}",
//                                       style: poppinsBold.copyWith(
//                                         fontSize: Dimensions.fontSizeExtraLarge,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                               if (orderProvider.trackModel!.orderStatus ==
//                                       'confirmed' ||
//                                   orderProvider.trackModel!.orderStatus ==
//                                       'processing' ||
//                                   orderProvider.trackModel!.orderStatus ==
//                                       'out_for_delivery')
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 24),
//                                   child: CustomButtonWidget(
//                                     buttonText: 'track_order'.tr,
//                                     onPressed: () {
//                                       Navigator.pushNamed(
//                                         context,
//                                         RouteHelper.getOrderTrackingRoute(
//                                           orderProvider.trackModel!.id,
//                                           widget.phoneNumber,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       if (ResponsiveHelper.isDesktop(context))
//                         Expanded(
//                             child: CustomScrollView(slivers: [
//                           if (ResponsiveHelper.isDesktop(context))
//                             SliverToBoxAdapter(
//                                 child: Center(
//                               child: Container(
//                                 width: Dimensions.webScreenWidth,
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: Dimensions.paddingSizeLarge),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Expanded(
//                                       flex: 6,
//                                       child: OrderInfoWidget(
//                                           orderModel: widget.orderModel,
//                                           timeSlot: timeSlot),
//                                     ),
//                                     const SizedBox(
//                                         width: Dimensions.paddingSizeLarge),
//                                     Expanded(
//                                       flex: 4,
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         children: [
//                                           OrderAmountWidget(
//                                             extraDiscount: extraDiscount,
//                                             itemsPrice: itemsPrice,
//                                             tax: tax,
//                                             subTotal: subTotal,
//                                             discount: discount,
//                                             couponDiscount: orderProvider
//                                                     .trackModel
//                                                     ?.couponDiscountAmount ??
//                                                 0,
//                                             deliveryCharge: deliveryCharge,
//                                             total: total,
//                                             isVatInclude: isVatInclude,
//                                             paymentList:
//                                                 OrderHelper.getPaymentList(
//                                                     orderProvider.trackModel),
//                                             orderModel: widget.orderModel,
//                                             phoneNumber: widget.phoneNumber,
//                                           ),
//                                           const SizedBox(
//                                             height:
//                                                 Dimensions.paddingSizeDefault,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )),
//                           const FooterWebWidget(footerType: FooterType.sliver),
//                         ])),
//                     ],
//                   )
//                 : NoDataWidget(
//                     isShowButton: true,
//                     image: Images.box,
//                     title: 'order_not_found'.tr);
//       }),
//     );
//   }

//   orderSummaryTile(BuildContext context, String title, String data,
//       [bool isPrice = false, bool isRed = false]) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: poppinsSemiBold,
//           ),
//           Text(
//             data + (!isPrice ? "" : " ${config!.currencySymbol ?? ""}"),
//             style: poppinsSemiBold.copyWith(
//               color: isRed ? Colors.red : null,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
