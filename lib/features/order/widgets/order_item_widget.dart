import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/cart_model.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/features/order/domain/models/order_model.dart';
import 'package:flutter_grocery/features/order/widgets/cancel_widget.dart';
import 'package:flutter_grocery/features/order/widgets/rating_widget.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/date_converter_helper.dart';
import 'package:flutter_grocery/helper/order_helper.dart';
import 'package:flutter_grocery/helper/price_converter_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/common/providers/product_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/features/order/screens/order_details_screen.dart';
import 'package:flutter_grocery/features/order/widgets/re_order_dialog_widget.dart';
import 'package:provider/provider.dart';

class OrderItemWidget extends StatefulWidget {
  const OrderItemWidget(
      {Key? key, required this.orderList, required this.index})
      : super(key: key);

  final List<OrderModel>? orderList;
  final int index;

  @override
  State<OrderItemWidget> createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  @override
  void initState() {
    // TODO: implement initState
    Provider.of<OrderProvider>(context, listen: false).getOrderList(context);
    Provider.of<OrderProvider>(context, listen: false).getCancelStatus();
  }

  @override
  Widget build(BuildContext context) {
    // double deliveryCharge = OrderHelper.getDeliveryCharge(
    //     orderModel:widget.orderList![widget.index].trackModel);
    // double itemsPrice = OrderHelper.getOrderDetailsValue(
    //   orderDetailsList: widget.orderList![widget.index].o,
    //   type: OrderValue.itemPrice,
    // );
    // double deliveryFee = OrderHelper.getOrderDetailsValue(
    //   orderDetailsList: orderProvider.orderDetails,
    //   type: OrderValue.deliveryFee,
    // );
    // double walletUsed = OrderHelper.getOrderDetailsValue(
    //   orderDetailsList: orderProvider.orderDetails,
    //   type: OrderValue.walletUsed,
    // );
    // double couponDiscount = OrderHelper.getOrderDetailsValue(
    //   orderDetailsList: orderProvider.orderDetails,
    //   type: OrderValue.couponDiscount,
    // );
    // double discount = OrderHelper.getOrderDetailsValue(
    //   orderDetailsList: orderProvider.orderDetails,
    //   type: OrderValue.discount,
    // );
    // double extraDiscount = OrderHelper.getExtraDiscount(
    //     trackOrder: orderProvider.trackModel);
    // double tax = OrderHelper.getOrderDetailsValue(
    //   orderDetailsList: orderProvider.orderDetails,
    //   type: OrderValue.tax,
    // );
    // bool isVatInclude = OrderHelper.isVatTaxInclude(
    //     orderDetailsList: orderProvider.orderDetails);
    // double subTotal = OrderHelper.getSubTotalAmount(
    //   itemsPrice: itemsPrice,
    //   tax: tax,
    //   isVatInclude: isVatInclude,
    // );
    // double total = OrderHelper.getTotalOrderAmount(
    //     subTotal: widget.orderList![widget.index].orderAmount!,
    //     discount: discount,
    //     extraDiscount: widget.orderList![widget.index].extraDiscount!,
    //     deliveryCharge: widget.orderList![widget.index].deliveryCharge!,
    //     couponDiscount: widget.orderList![widget.index].couponDiscountAmount!,
    //     // couponDiscount: orderProvider.trackModel?.couponDiscountAmount,
    //     walletUsed: widget.orderList![widget.index].);
    print(
        'status order ${widget.orderList![widget.index].id} ${widget.orderList![widget.index].orderStatus}');
    String _getOrderStatusText(int status) {
      switch (status) {
        case 1:
          return 'Under Review';
        case 2:
          return 'Return By Replacement';
        case 3:
          return 'Return To Wallet';
        case 4:
          return 'Return By Cash';
        case 5:
          return 'Return Request Declined';
        default:
          return ''; // If status doesn't match any of the cases, return an empty string
      }
    }

    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.isDesktop(context)
            ? 30
            : Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        // boxShadow: [
        //   BoxShadow(
        //     color: Theme.of(context).shadowColor.withOpacity(0.5),
        //     spreadRadius: 1,
        //     blurRadius: 5,
        //   )
        // ],
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
      ),
      child: ResponsiveHelper.isDesktop(context)
          ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Row(children: [
                  Text(
                    '${getTranslated('order_id', context)} #',
                    style: poppinsBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                  Text(widget.orderList![widget.index].id.toString(),
                      style: poppinsSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault)),
                ]),
              ),
              Expanded(
                child: Center(
                  child: Text(
                      '${'date'.tr}: ${DateConverterHelper.isoStringToLocalDateOnly(widget.orderList![widget.index].updatedAt!)}',
                      style: poppinsMedium),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                      '${widget.orderList![widget.index].totalQuantity} ${getTranslated(widget.orderList![widget.index].totalQuantity == 1 ? 'item' : 'items', context)}',
                      style: poppinsSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault)
                      // style: poppinsRegular.copyWith(
                      //     color: Theme.of(context).disabledColor),
                      ),
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _OrderStatusCard(
                      orderList: widget.orderList, index: widget.index),
                ],
              )),
              widget.orderList![widget.index].orderType != 'pos'
                  ? Consumer<ProductProvider>(
                      builder: (context, productProvider, _) =>
                          Consumer<OrderProvider>(
                              builder: (context, orderProvider, _) {
                            bool isReOrderAvailable =
                                orderProvider.getReOrderIndex == null ||
                                    (orderProvider.getReOrderIndex != null &&
                                        productProvider.product != null);

                            return (orderProvider.isLoading ||
                                        productProvider.product == null) &&
                                    widget.index ==
                                        orderProvider.getReOrderIndex &&
                                    !orderProvider.isActiveOrder
                                ? Expanded(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                        CustomLoaderWidget(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ]))
                                : Expanded(
                                    child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      _TrackOrderView(
                                          orderList: widget.orderList,
                                          index: widget.index,
                                          isReOrderAvailable:
                                              isReOrderAvailable),
                                    ],
                                  ));
                          }))
                  : const Expanded(child: SizedBox()),
            ])
          : Row(
              children: [
                // Put Image here if there is any

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${getTranslated('order_id', context)} #${widget.orderList![widget.index].id.toString().length > 7 ? widget.orderList![widget.index].id.toString().substring(0, 7) : widget.orderList![widget.index].id.toString()}',
                          style: poppinsBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),

                        // Text(
                        //   '${getTranslated('order_id', context)} #${widget.orderList![widget.index].id.toString()}',
                        //   style: poppinsBold.copyWith(
                        //     fontSize: Dimensions.fontSizeLarge,
                        //   ),
                        // ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.07,
                        ),
                        // SizedBox(
                        //   width: MediaQuery.of(context).size.width * 0.053,
                        // ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // Set the background color to white
                            borderRadius: BorderRadius.circular(
                                8), // Adjust the radius as needed
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4), // Add padding to the container
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            _getOrderStatusText(
                                widget.orderList![widget.index].isReturned!),
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.027,
                              color: Colors
                                  .red, // Set text color to red for negative statuses
                            ),
                          ),
                        ),
                      ],
                    ),
                    widget.orderList![widget.index].returnReference != null
                        ? Text(
                            overflow: TextOverflow.ellipsis,
                            '${getTranslated('Reference ID', context)} #${widget.orderList![widget.index].returnReference.toString()}',
                            style: poppinsBold.copyWith(
                              fontSize: MediaQuery.of(context).size.width *
                                  0.03, // Adjust font size based on screen width
                              color: Colors.red,
                            ),
                          )
                        : const SizedBox(),
                    if (widget.orderList![widget.index].orderNote != null)
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              final screenHeight =
                                  MediaQuery.of(context).size.height;
                              final screenWidth =
                                  MediaQuery.of(context).size.width;

                              return Container(
                                constraints: BoxConstraints(
                                  maxHeight: screenHeight *
                                      0.7, // 70% of screen height
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(screenWidth *
                                        0.05), // 5% of screen width
                                    topRight:
                                        Radius.circular(screenWidth * 0.05),
                                  ),
                                ),
                                padding: EdgeInsets.all(
                                    screenWidth * 0.04), // 4% of screen width
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Order Note',
                                          style: poppinsMedium.copyWith(
                                            fontSize: screenWidth *
                                                0.045, // 4.5% of screen width
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            size: screenWidth *
                                                0.06, // 6% of screen width
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight *
                                            0.01, // 1% of screen height
                                      ),
                                      child: Text(
                                        "${widget.orderList![widget.index].orderNote}",
                                        style: poppinsMedium.copyWith(
                                          fontSize: screenWidth *
                                              0.04, // 4% of screen width
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width *
                                  0.008), // 2% of screen width
                          margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height *
                                0.01, // 1% of screen height
                          ),
                          // decoration: BoxDecoration(
                          //   color: Colors.grey[100],
                          //   borderRadius: BorderRadius.circular(
                          //     MediaQuery.of(context).size.width *
                          //         0.02, // 2% of screen width
                          //   ),
                          //   border: Border.all(color: Colors.grey[300]!),
                          // ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  "Order Notes",
                                  style: poppinsMedium.copyWith(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.035, // 3.5% of screen width
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.01), // 1% of screen width
                              Icon(
                                Icons.note,
                                size: MediaQuery.of(context).size.width *
                                    0.04, // 4% of screen width
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    Text(
                      DateConverterHelper.isoStringToOrderDetailsDateTime(
                        widget.orderList![widget.index].updatedAt!,
                      ),
                      style: poppinsMedium.copyWith(
                        color: Theme.of(context).disabledColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                    //const SizedBox(height: Dimensions.paddingSizeSmall),
                    // Expanded(
                    //   child: Center(
                    //child:
                    Text(
                        '${widget.orderList![widget.index].totalQuantity} ${getTranslated(widget.orderList![widget.index].totalQuantity == 1 ? 'item' : 'items', context)}',
                        style: poppinsSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault)
                        // style: poppinsRegular.copyWith(
                        //     color: Theme.of(context).disabledColor),
                        ),
                    //   ),
                    // ),
                    Builder(builder: (context) {
                      final ConfigModel config =
                          Provider.of<SplashProvider>(context, listen: false)
                              .configModel!;
                      return Text(
                        PriceConverterHelper.convertPrice(context,
                            widget.orderList![widget.index].orderAmount),
                        // '${widget.orderList![widget.index].orderAmount!.toStringAsFixed(2)} ${config.currencySymbol}',
                        style: poppinsBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                        ),
                      );
                    }),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    widget.orderList![widget.index].orderStatus == 'canceled'
                        ? Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    RouteHelper.getOrderDetailsRoute(
                                        '${widget.orderList?[widget.index].id}'),
                                    arguments: OrderDetailsScreen(
                                        orderId:
                                            widget.orderList![widget.index].id,
                                        orderModel:
                                            widget.orderList![widget.index]),
                                  );
                                },
                                child: Container(
                                  height: 40,
                                  width:
                                      MediaQuery.of(context).size.width / 3.5,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    getTranslated("order_details", context),
                                    style: poppinsSemiBold.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      letterSpacing: 1.2,
                                      wordSpacing: 1.6,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.02,
                              ),
                              if (widget.orderList![widget.index].orderType !=
                                  'pos')
                                const SizedBox(width: 12),
                              if (widget.orderList![widget.index].orderType !=
                                  'pos')
                                Consumer<ProductProvider>(
                                  builder: (context, productProvider, _) =>
                                      Consumer<OrderProvider>(
                                    builder: (context, orderProvider, _) {
                                      bool isReOrderAvailable = orderProvider
                                                  .getReOrderIndex ==
                                              null ||
                                          (orderProvider.getReOrderIndex !=
                                                  null &&
                                              productProvider.product != null);

                                      return Row(
                                        children: [
                                          (orderProvider.isLoading ||
                                                      productProvider.product ==
                                                          null) &&
                                                  widget.index ==
                                                      orderProvider
                                                          .getReOrderIndex &&
                                                  !orderProvider.isActiveOrder
                                              ? CustomLoaderWidget(
                                                  color: Theme.of(context)
                                                      .primaryColor)
                                              : GestureDetector(
                                                  onTap: () async {
                                                    if (orderProvider
                                                        .isActiveOrder) {
                                                      Navigator.of(context)
                                                          .pushNamed(RouteHelper
                                                              .getOrderTrackingRoute(
                                                                  widget
                                                                      .orderList![
                                                                          widget
                                                                              .index]
                                                                      .id,
                                                                  null));
                                                    } else {
                                                      if (!orderProvider
                                                              .isLoading &&
                                                          isReOrderAvailable) {
                                                        orderProvider
                                                                .setReorderIndex =
                                                            widget.index;
                                                        List<
                                                                CartModel>?
                                                            cartList =
                                                            await orderProvider.reorderProduct(
                                                                widget
                                                                    .orderList![
                                                                        widget
                                                                            .index]
                                                                    .totalQuantity,
                                                                '${widget.orderList![widget.index].id}');
                                                        if (cartList != null &&
                                                            cartList
                                                                .isNotEmpty) {
                                                          showDialog(
                                                              context:
                                                                  Get.context!,
                                                              builder: (context) =>
                                                                  const ReOrderDialogWidget());
                                                        }
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 40,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            4,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      getTranslated(
                                                          orderProvider
                                                                  .isActiveOrder
                                                              ? 'track_order'
                                                              : 're_order',
                                                          context),
                                                      style: poppinsSemiBold
                                                          .copyWith(
                                                        color: Colors.white,
                                                        letterSpacing: 1.2,
                                                        wordSpacing: 1.6,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          // if (orderProvider.isActiveOrder)
                                          //   GestureDetector(
                                          //     onTap: () {
                                          //       Navigator.of(context).pushNamed(
                                          //         RouteHelper.getOrderDetailsRoute(
                                          //             '${widget.orderList?[widget.index].id}'),
                                          //         arguments: OrderDetailsScreen(
                                          //             orderId: widget
                                          //                 .orderList![widget.index]
                                          //                 .id,
                                          //             orderModel: widget
                                          //                 .orderList![widget.index]),
                                          //       );
                                          //     },
                                          //     child: Container(
                                          //       height: 40,
                                          //       width: MediaQuery.of(context)
                                          //               .size
                                          //               .width /
                                          //           3.5,
                                          //       decoration: BoxDecoration(
                                          //         color:
                                          //             Theme.of(context).primaryColor,
                                          //         borderRadius:
                                          //             BorderRadius.circular(8),
                                          //       ),
                                          //       alignment: Alignment.center,
                                          //       child: Text(
                                          //         getTranslated(
                                          //             "Order Cancel", context),
                                          //         style: poppinsSemiBold.copyWith(
                                          //           color: Colors.white,
                                          //           letterSpacing: 1.2,
                                          //           wordSpacing: 1.6,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.02,
                              ),
                              Container(
                                height: 40,
                                width: MediaQuery.of(context).size.width / 4.5,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  getTranslated('Cancelled', context),
                                  style: poppinsSemiBold.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 1,
                                    wordSpacing: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    RouteHelper.getOrderDetailsRoute(
                                        '${widget.orderList?[widget.index].id}'),
                                    arguments: OrderDetailsScreen(
                                        orderId:
                                            widget.orderList![widget.index].id,
                                        orderModel:
                                            widget.orderList![widget.index]),
                                  );
                                },
                                child: Container(
                                  height: 40,
                                  width:
                                      MediaQuery.of(context).size.width / 3.5,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    getTranslated("order_details", context),
                                    style: poppinsSemiBold.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      letterSpacing: 1.2,
                                      wordSpacing: 1.6,
                                    ),
                                  ),
                                ),
                              ),

                              // Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     crossAxisAlignment: CrossAxisAlignment.end,
                              //     children: [
                              // Padding(
                              //   padding: const EdgeInsets.only(bottom: 3),
                              //   child: _OrderStatusCard(
                              //       orderList: orderList, index: index),
                              // ),
                              // orderList![index].orderType != 'pos'
                              //     ? Consumer<ProductProvider>(
                              //         builder: (context, productProvider, _) =>
                              //             Consumer<OrderProvider>(
                              //                 builder: (context, orderProvider, _) {
                              //               bool isReOrderAvailable = orderProvider
                              //                           .getReOrderIndex ==
                              //                       null ||
                              //                   (orderProvider.getReOrderIndex !=
                              //                           null &&
                              //                       productProvider.product != null);

                              //               return (orderProvider.isLoading ||
                              //                           productProvider.product ==
                              //                               null) &&
                              //                       index ==
                              //                           orderProvider
                              //                               .getReOrderIndex &&
                              //                       !orderProvider.isActiveOrder
                              //                   ? CustomLoaderWidget(
                              //                       color: Theme.of(context)
                              //                           .primaryColor)
                              //                   : _TrackOrderView(
                              //                       orderList: orderList,
                              //                       index: index,
                              //                       isReOrderAvailable:
                              //                           isReOrderAvailable);
                              //             }))
                              //     : const SizedBox.shrink(),
                              // ]),
                              if (widget.orderList![widget.index].orderType !=
                                  'pos')
                                const SizedBox(width: 12),
                              if (widget.orderList![widget.index].orderType !=
                                  'pos')
                                Consumer<ProductProvider>(
                                  builder: (context, productProvider, _) =>
                                      Consumer<OrderProvider>(
                                    builder: (context, orderProvider, _) {
                                      bool isReOrderAvailable = orderProvider
                                                  .getReOrderIndex ==
                                              null ||
                                          (orderProvider.getReOrderIndex !=
                                                  null &&
                                              productProvider.product != null);

                                      return Row(
                                        children: [
                                          (orderProvider.isLoading ||
                                                      productProvider.product ==
                                                          null) &&
                                                  widget.index ==
                                                      orderProvider
                                                          .getReOrderIndex &&
                                                  !orderProvider.isActiveOrder
                                              ? CustomLoaderWidget(
                                                  color: Theme.of(context)
                                                      .primaryColor)
                                              : GestureDetector(
                                                  onTap: () async {
                                                    if (orderProvider
                                                        .isActiveOrder) {
                                                      Navigator.of(context)
                                                          .pushNamed(RouteHelper
                                                              .getOrderTrackingRoute(
                                                                  widget
                                                                      .orderList![
                                                                          widget
                                                                              .index]
                                                                      .id,
                                                                  null));
                                                    } else {
                                                      if (!orderProvider
                                                              .isLoading &&
                                                          isReOrderAvailable) {
                                                        orderProvider
                                                                .setReorderIndex =
                                                            widget.index;
                                                        List<
                                                                CartModel>?
                                                            cartList =
                                                            await orderProvider.reorderProduct(
                                                                widget
                                                                    .orderList![
                                                                        widget
                                                                            .index]
                                                                    .totalQuantity,
                                                                '${widget.orderList![widget.index].id}');
                                                        if (cartList != null &&
                                                            cartList
                                                                .isNotEmpty) {
                                                          showDialog(
                                                              context:
                                                                  Get.context!,
                                                              builder: (context) =>
                                                                  const ReOrderDialogWidget());
                                                        }
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 40,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            4,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      getTranslated(
                                                          orderProvider
                                                                  .isActiveOrder
                                                              ? 'track_order'
                                                              : 're_order',
                                                          context),
                                                      style: poppinsSemiBold
                                                          .copyWith(
                                                        color: Colors.white,
                                                        letterSpacing: 1.2,
                                                        wordSpacing: 1.6,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          // if (orderProvider.isActiveOrder)
                                          //   GestureDetector(
                                          //     onTap: () {
                                          //       Navigator.of(context).pushNamed(
                                          //         RouteHelper.getOrderDetailsRoute(
                                          //             '${widget.orderList?[widget.index].id}'),
                                          //         arguments: OrderDetailsScreen(
                                          //             orderId: widget
                                          //                 .orderList![widget.index]
                                          //                 .id,
                                          //             orderModel: widget
                                          //                 .orderList![widget.index]),
                                          //       );
                                          //     },
                                          //     child: Container(
                                          //       height: 40,
                                          //       width: MediaQuery.of(context)
                                          //               .size
                                          //               .width /
                                          //           3.5,
                                          //       decoration: BoxDecoration(
                                          //         color:
                                          //             Theme.of(context).primaryColor,
                                          //         borderRadius:
                                          //             BorderRadius.circular(8),
                                          //       ),
                                          //       alignment: Alignment.center,
                                          //       child: Text(
                                          //         getTranslated(
                                          //             "Order Cancel", context),
                                          //         style: poppinsSemiBold.copyWith(
                                          //           color: Colors.white,
                                          //           letterSpacing: 1.2,
                                          //           wordSpacing: 1.6,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.02,
                              ),
                              Consumer<OrderProvider>(
                                  builder: (context, orderProvider, _) {
                                return orderProvider.isActiveOrder &&
                                        Provider.of<OrderProvider>(context,
                                                    listen: false)
                                                .returnStatus ==
                                            '1'
                                    ? GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: ReturnScreen(
                                                  orderId: widget
                                                      .orderList![widget.index]
                                                      .id!,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            getTranslated("Cancel", context),
                                            style: poppinsSemiBold.copyWith(
                                              color: Colors.white,
                                              letterSpacing: 1.2,
                                              wordSpacing: 1.6,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox();
                              }),
//--------------------------------------------------------------------------------------------------------------------
                              Consumer<OrderProvider>(
                                  builder: (context, orderProvider, _) {
                                return orderProvider.isActiveOrder
                                    ? SizedBox()
                                    : GestureDetector(
                                        onTap: () {
                                          // orderProvider.isActiveOrder
                                          //     ? showDialog(
                                          //         context: context,
                                          //         builder:
                                          //             (BuildContext context) {
                                          //           return Dialog(
                                          //             shape:
                                          //                 RoundedRectangleBorder(
                                          //               borderRadius:
                                          //                   BorderRadius
                                          //                       .circular(10.0),
                                          //             ),
                                          //             child: ReturnScreen(
                                          //               orderId: widget
                                          //                   .orderList![
                                          //                       widget.index]
                                          //                   .id!,
                                          //             ),
                                          //           );
                                          //         },
                                          //       )
                                          //:
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: RatingScreen(
                                                  orderId: widget
                                                      .orderList![widget.index]
                                                      .id!,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          height: 40,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            getTranslated(
                                                // orderProvider.isActiveOrder &&
                                                //         widget
                                                //                 .orderList![
                                                //                     widget
                                                //                         .index]
                                                //                 .orderStatus !=
                                                //             'canceled' &&
                                                //         Provider.of<OrderProvider>(
                                                //                     context,
                                                //                     listen:
                                                //                         false)
                                                //                 .returnStatus ==
                                                //             '1'
                                                //     ? "Cancel"
                                                //:
                                                'Rate Us',
                                                context),
                                            style: poppinsSemiBold.copyWith(
                                              color: Colors.white,
                                              letterSpacing: 1.2,
                                              wordSpacing: 1.6,
                                            ),
                                          ),
                                        ),
                                      );
                              }),
                              // Consumer<OrderProvider>(
                              //     builder: (context, orderProvider, _) {
                              //   return GestureDetector(
                              //     onTap: () {
                              //       orderProvider.isActiveOrder
                              //           ? showDialog(
                              //               context: context,
                              //               builder: (BuildContext context) {
                              //                 return Dialog(
                              //                   shape: RoundedRectangleBorder(
                              //                     borderRadius:
                              //                         BorderRadius.circular(
                              //                             10.0),
                              //                   ),
                              //                   child: ReturnScreen(
                              //                     orderId: widget
                              //                         .orderList![widget.index]
                              //                         .id!,
                              //                   ),
                              //                 );
                              //               },
                              //             )
                              //           : showDialog(
                              //               context: context,
                              //               builder: (BuildContext context) {
                              //                 return Dialog(
                              //                   shape: RoundedRectangleBorder(
                              //                     borderRadius:
                              //                         BorderRadius.circular(
                              //                             10.0),
                              //                   ),
                              //                   child: RatingScreen(
                              //                     orderId: widget
                              //                         .orderList![widget.index]
                              //                         .id!,
                              //                   ),
                              //                 );
                              //               },
                              //             );
                              //     },
                              //     child: Container(
                              //       height: 40,
                              //       width:
                              //           MediaQuery.of(context).size.width / 4,
                              //       decoration: BoxDecoration(
                              //         color: Theme.of(context).primaryColor,
                              //         borderRadius: BorderRadius.circular(8),
                              //       ),
                              //       alignment: Alignment.center,
                              //       child: Text(
                              //         getTranslated(
                              //             orderProvider.isActiveOrder &&
                              //                     widget
                              //                             .orderList![
                              //                                 widget.index]
                              //                             .orderStatus !=
                              //                         'canceled'
                              //                 ? "Cancel"
                              //                 : 'Rate Us',
                              //             context),
                              //         style: poppinsSemiBold.copyWith(
                              //           color: Colors.white,
                              //           letterSpacing: 1.2,
                              //           wordSpacing: 1.6,
                              //         ),
                              //       ),
                              //     ),
                              //   );
                              // }),
                              // Padding(
                              //   padding: const EdgeInsets.only(bottom: 3),
                              //   child: _OrderStatusCard(
                              //       orderList: orderList, index: index),
                              // ),
                              // orderList![index].orderType != 'pos'
                              //     ? Consumer<ProductProvider>(
                              //         builder: (context, productProvider, _) =>
                              //             Consumer<OrderProvider>(
                              //           builder: (context, orderProvider, _) {
                              //             bool isReOrderAvailable =
                              //                 orderProvider.getReOrderIndex == null ||
                              //                     (orderProvider.getReOrderIndex !=
                              //                             null &&
                              //                         productProvider.product !=
                              //                             null);

                              //             return (orderProvider.isLoading ||
                              //                         productProvider.product ==
                              //                             null) &&
                              //                     index ==
                              //                         orderProvider.getReOrderIndex &&
                              //                     !orderProvider.isActiveOrder
                              //                 ? CustomLoaderWidget(
                              //                     color:
                              //                         Theme.of(context).primaryColor)
                              //                 : _TrackOrderView(
                              //                     orderList: orderList,
                              //                     index: index,
                              //                     isReOrderAvailable:
                              //                         isReOrderAvailable,
                              //                   );
                              //           },
                              //         ),
                              //       )
                              //     : const SizedBox.shrink(),
                            ],
                          ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _TrackOrderView extends StatelessWidget {
  const _TrackOrderView(
      {Key? key,
      required this.orderList,
      required this.index,
      required this.isReOrderAvailable})
      : super(key: key);

  final List<OrderModel>? orderList;
  final int index;
  final bool isReOrderAvailable;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(builder: (context, orderProvider, child) {
      return TextButton(
        style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
            )),
        onPressed: () async {
          if (orderProvider.isActiveOrder) {
            Navigator.of(context).pushNamed(
                RouteHelper.getOrderTrackingRoute(orderList![index].id, null));
          } else {
            if (!orderProvider.isLoading && isReOrderAvailable) {
              orderProvider.setReorderIndex = index;
              List<CartModel>? cartList = await orderProvider.reorderProduct(
                  orderList![index].totalQuantity, '${orderList![index].id}');
              if (cartList != null && cartList.isNotEmpty) {
                showDialog(
                    context: Get.context!,
                    builder: (context) => const ReOrderDialogWidget());
              }
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault),
          child: Text(
            getTranslated(
                orderProvider.isActiveOrder ? 'track_order' : 're_order',
                context),
            style: poppinsRegular.copyWith(
              color: Theme.of(context).cardColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ),
      );
    });
  }
} // class _TrackOrderView extends StatelessWidget {
//   const _TrackOrderView(
//       {Key? key,
//       required this.orderList,
//       required this.index,
//       required this.isReOrderAvailable})
//       : super(key: key);

//   final List<OrderModel>? orderList;
//   final int index;
//   final bool isReOrderAvailable;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<OrderProvider>(builder: (context, orderProvider, child) {
//       return TextButton(
//         style: TextButton.styleFrom(
//             backgroundColor: Theme.of(context).primaryColor,
//             padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
//             )),
//         onPressed: () async {},
//         child: Padding(
//           padding: const EdgeInsets.symmetric(
//               horizontal: Dimensions.paddingSizeDefault),
//           child: Text(
//             getTranslated(
//                 orderProvider.isActiveOrder ? 'track_order' : 're_order',
//                 context),
//             style: poppinsRegular.copyWith(
//               color: Theme.of(context).cardColor,
//               fontSize: Dimensions.fontSizeDefault,
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }

class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard(
      {Key? key, required this.orderList, required this.index})
      : super(key: key);

  final List<OrderModel>? orderList;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: OrderStatus.pending.name == orderList![index].orderStatus
            ? ColorResources.colorBlue.withOpacity(0.08)
            : OrderStatus.out_for_delivery.name == orderList![index].orderStatus
                ? ColorResources.ratingColor.withOpacity(0.08)
                : OrderStatus.canceled.name == orderList![index].orderStatus
                    ? ColorResources.redColor.withOpacity(0.08)
                    : ColorResources.colorGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
      ),
      child: Text(
        getTranslated(orderList![index].orderStatus, context),
        style: poppinsRegular.copyWith(
            color: OrderStatus.pending.name == orderList![index].orderStatus
                ? ColorResources.colorBlue
                : OrderStatus.out_for_delivery.name ==
                        orderList![index].orderStatus
                    ? ColorResources.ratingColor
                    : OrderStatus.canceled.name == orderList![index].orderStatus
                        ? ColorResources.redColor
                        : ColorResources.colorGreen),
      ),
    );
  }
}
